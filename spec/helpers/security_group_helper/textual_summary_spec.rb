describe SecurityGroupHelper::TextualSummary do
  describe ".textual_group_firewall" do
    before do
      login_as FactoryGirl.create(:user)
    end

    subject { textual_group_firewall }
    it 'returns TextualTable struct with list of of firewall rules' do
      firewall_rules = [
        FactoryGirl.create(:firewall_rule, :name => "Foo", :display_name => "Foo", :port => 1234),
        FactoryGirl.create(:firewall_rule, :name => "Foo", :display_name => "Foo")
      ]
      @record = FactoryGirl.create(:security_group_with_firewall_rules, :firewall_rules => firewall_rules)
      expect(subject).to be_kind_of(Struct)
    end
  end

  include_examples "textual_group", "Properties", %i(description type)

  include_examples "textual_group", "Relationships", %i(
    parent_ems_cloud
    ems_network
    cloud_tenant
    instances
    orchestration_stack
    network_ports
  )
end
