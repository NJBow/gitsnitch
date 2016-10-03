require './lib/octokit_search'


class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def github
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      account_verified
      octokit_client
    else
      account_not_verified
    end
  end

  def account_verified
    sign_in_and_redirect @user, :event => :authentication
    set_flash_message(:notice, :success, :kind => "Github") if is_navigational_format?
  end

  def account_not_verified
    redirect_to new_user_registration_url
  end

  def failure
    redirect_to root_path
  end

  def octokit_client
    username = request.env["omniauth.auth"]["info"]["nickname"]
    @client = OctokitSearch.new(username)
    @client.search_manager
    github_results
  end

  def github_results

    issue = Issue.new
    issue.url = @client.results[0][:url].to_s
    issue.raw = @client.results[0][:raw].to_s
    issue.fragment = @client.results[0][:fragment].to_s
    issue.user = User.first
    issue.save
    # Issue.create(url: 'test', raw: 'test', fragment: 'test')
    p "========================#{Issue.first.inspect}"
    # session[:html] = @client.results
  end

end
