describe ApplicationHelper::Button::CloudSubnetNew do
  include ApplicationHelper

  describe '#disabled?' do
    it "when at least one provider supports subnet create then the button is not disabled" do
      view_context = setup_view_context_with_sandbox({})
      FactoryBot.create(:ems_openstack)
      button = described_class.new(view_context, {}, {}, {})
      expect(button.disabled?).to be false
    end

    it "when only Telefonica provider supports subnet create then the button is not disabled" do
      view_context = setup_view_context_with_sandbox({})
      FactoryBot.create(:ems_telefonica)
      button = described_class.new(view_context, {}, {}, {})
      expect(button.disabled?).to be false
    end

    it "when only Orange provider supports subnet create then the button is not disabled" do
      view_context = setup_view_context_with_sandbox({})
      FactoryBot.create(:ems_orange)
      button = described_class.new(view_context, {}, {}, {})
      expect(button.disabled?).to be false
    end

    it "when at least one provider supports subnet create then the button is not disabled" do
      view_context = setup_view_context_with_sandbox({})
      FactoryBot.create(:ems_openstack)
      button = described_class.new(view_context, {}, {}, {})
      expect(button.disabled?).to be false
    end

    it "when no provider supports subnet create then the button is disabled" do
      view_context = setup_view_context_with_sandbox({})
      button = described_class.new(view_context, {}, {}, {})
      expect(button.disabled?).to be true
    end
  end

  describe '#calculate_properties' do
    it "when no provider supports subnet create the button has an error in the title" do
      view_context = setup_view_context_with_sandbox({})
      button = described_class.new(view_context, {}, {}, {})
      button.calculate_properties
      expect(button[:title]).to eq("No cloud providers support creating cloud subnets.")
    end

    it "when at least one provider supports subnet create, the button has no error in the title" do
      view_context = setup_view_context_with_sandbox({})
      FactoryBot.create(:ems_openstack)
      button = described_class.new(view_context, {}, {}, {})
      button.calculate_properties
      expect(button[:title]).to be nil
    end
  end
end
