class ApplicationHelper::Button::NewCloudTenant < ApplicationHelper::Button::ButtonNewDiscover

  # Click2Cloud: Added orange cloudmanager condition
  def disabled?
    super || ManageIQ::Providers::Openstack::CloudManager.count == 0 || ManageIQ::Providers::Orange::CloudManager.count == 0 || ManageIQ::Providers::Telefonica::CloudManager.count == 0
  end
end
