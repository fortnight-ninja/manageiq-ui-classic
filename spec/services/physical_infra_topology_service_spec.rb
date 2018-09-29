describe PhysicalInfraTopologyService do
  # The following physical tree is going to be used to test the topology mount
  # - Provider
  #   - Rack A
  #     - Chassis A
  #       - Server A
  #     - Server B
  #   - Chassis B
  #     - Server C
  #   - Server D

  let(:server_a) { FactoryGirl.create(:physical_server, :name => 'Server A', :health_state => 'Error') }
  let(:server_b) { FactoryGirl.create(:physical_server, :name => 'Server B', :health_state => 'Warning') }
  let(:server_c) { FactoryGirl.create(:physical_server, :name => 'Server C', :health_state => 'Valid') }
  let(:server_d) { FactoryGirl.create(:physical_server, :name => 'Server D', :health_state => 'Error') }

  let(:chassis_a) do
    FactoryGirl.create(:physical_chassis,
                       :name             => 'Chassis A',
                       :health_state     => 'Valid',
                       :physical_servers => [server_a])
  end

  let(:chassis_b) do
    FactoryGirl.create(:physical_chassis,
                       :name             => 'Chassis B',
                       :health_state     => 'Error',
                       :physical_servers => [server_c])
  end

  let(:rack_a) do
    FactoryGirl.create(:physical_rack,
                       :name             => 'Rack A',
                       :physical_chassis => [chassis_a],
                       :physical_servers => [server_a, server_b])
  end

  let(:auth) do
    FactoryGirl.create(:authentication,
                       :userid   => 'admin',
                       :password => 'password',
                       :authtype => 'default')
  end

  let(:ems) do
    ems = FactoryGirl.create(:physical_infra,
                             :name      => 'LXCA',
                             :hostname  => 'example.com',
                             :port      => '443',
                             :ipaddress => '1.2.3.4')
    ems.authentications = [auth]
    ems.physical_racks = [rack_a]
    ems.physical_chassis = [chassis_a, chassis_b]
    ems.physical_servers = [server_a, server_b, server_c, server_d]
    ems
  end

  let(:physical_infra_topology_service) { described_class.new(nil) }

  describe "#build_topology" do
    subject { physical_infra_topology_service.build_topology }

    it "topology contains only the expected keys" do
      expect(subject.keys).to match_array(%i(items kinds filter_properties relations icons))
    end

    it "topology contains the expected structure and content" do
      allow(physical_infra_topology_service).to receive(:retrieve_providers).and_return([ems])
      physical_infra_topology_service.instance_variable_set(:@entity, ems)

      expect(subject[:items]).to eq(
        "PhysicalInfraManager" + ems.id.to_s  => {
          :name         => ems.name,
          :kind         => "PhysicalInfraManager",
          :miq_id       => ems.id,
          :status       => nil,
          :display_kind => "Lenovo",
          :model        => ems.class.name,
          :key          => "PhysicalInfraManager" + ems.id.to_s
        },
        "PhysicalRack" + rack_a.id.to_s       => {
          :name         => rack_a.name,
          :kind         => "PhysicalRack",
          :miq_id       => rack_a.id,
          :status       => "Unknown",
          :display_kind => "PhysicalRack",
          :provider     => ems.name,
          :model        => rack_a.class.name,
          :key          => "PhysicalRack" + rack_a.id.to_s
        },
        "PhysicalChassis" + chassis_a.id.to_s => {
          :name         => chassis_a.name,
          :kind         => "PhysicalChassis",
          :miq_id       => chassis_a.id,
          :status       => "Valid",
          :display_kind => "PhysicalChassis",
          :provider     => ems.name,
          :model        => chassis_a.class.name,
          :key          => "PhysicalChassis" + chassis_a.id.to_s
        },
        "PhysicalChassis" + chassis_b.id.to_s => {
          :name         => chassis_b.name,
          :kind         => "PhysicalChassis",
          :miq_id       => chassis_b.id,
          :status       => "Error",
          :display_kind => "PhysicalChassis",
          :provider     => ems.name,
          :model        => chassis_b.class.name,
          :key          => "PhysicalChassis" + chassis_b.id.to_s
        },
        "PhysicalServer" + server_a.id.to_s   => {
          :name         => server_a.name,
          :kind         => "PhysicalServer",
          :miq_id       => server_a.id,
          :status       => "Error",
          :display_kind => "PhysicalServer",
          :provider     => ems.name,
          :model        => server_a.class.name,
          :key          => "PhysicalServer" + server_a.id.to_s
        },
        "PhysicalServer" + server_b.id.to_s   => {
          :name         => server_b.name,
          :kind         => "PhysicalServer",
          :miq_id       => server_b.id,
          :status       => "Warning",
          :display_kind => "PhysicalServer",
          :provider     => ems.name,
          :model        => server_b.class.name,
          :key          => "PhysicalServer" + server_b.id.to_s
        },
        "PhysicalServer" + server_c.id.to_s   => {
          :name         => server_c.name,
          :kind         => "PhysicalServer",
          :miq_id       => server_c.id,
          :status       => "Valid",
          :display_kind => "PhysicalServer",
          :provider     => ems.name,
          :model        => server_c.class.name,
          :key          => "PhysicalServer" + server_c.id.to_s
        },
        "PhysicalServer" + server_d.id.to_s   => {
          :name         => server_d.name,
          :kind         => "PhysicalServer",
          :miq_id       => server_d.id,
          :status       => "Error",
          :display_kind => "PhysicalServer",
          :provider     => ems.name,
          :model        => server_d.class.name,
          :key          => "PhysicalServer" + server_d.id.to_s
        }
      )

      expect(subject[:relations].size).to eq(7)
      expect(subject[:relations]).to include(
        {:source => "PhysicalInfraManager" + ems.id.to_s, :target => "PhysicalRack" + rack_a.id.to_s},
        {:source => "PhysicalRack" + rack_a.id.to_s, :target => "PhysicalChassis" + chassis_a.id.to_s},
        {:source => "PhysicalChassis" + chassis_a.id.to_s, :target => "PhysicalServer" + server_a.id.to_s},
        {:source => "PhysicalRack" + rack_a.id.to_s, :target => "PhysicalServer" + server_b.id.to_s},
        {:source => "PhysicalInfraManager" + ems.id.to_s, :target => "PhysicalChassis" + chassis_b.id.to_s},
        {:source => "PhysicalChassis" + chassis_b.id.to_s, :target => "PhysicalServer" + server_c.id.to_s},
        {:source => "PhysicalInfraManager" + ems.id.to_s, :target => "PhysicalServer" + server_d.id.to_s},
      )
    end
  end
end
