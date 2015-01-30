
## Common functions to be used in controller tests
module ControllerMacros
  def login_user
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      user = FactoryGirl.create(:krikri_user)
      sign_in user
    end
  end
end
