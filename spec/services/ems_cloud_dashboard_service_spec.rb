describe EmsCloudDashboardService do
  context '#recentInstances' do
    before(:each) do
      @ems1 = FactoryGirl.create(:ems_cloud)
      @vm1 = FactoryGirl.create(:vm_openstack, :ext_management_system => @ems1)
      @vm2 = FactoryGirl.create(:vm_openstack, :ext_management_system => @ems1, :created_on => 1.day.ago.utc)
    end

    subject { EmsCloudDashboardService.new(@ems1.id, "ems_cloud", EmsCloud) }

    it 'returns instances for a specified provider' do
      expect(subject.recent_instances_data[:recentResources][:xData].count).to eq(2)
      expect(subject.recent_instances_data[:recentResources][:yData].count).to eq(2)
    end
  end
end
