ActionController::Routing::Routes.draw do |map|
  map.resource :session

  map.auto_complete ':controller/:action',
    :requirements => { :action => /auto_complete_for_\S+/ },
    :conditions => { :method => :post }

  map.in_place_edit ':controller/:id/:action',
    :requirements => { :action => /set_[^\/]+/ },
    :conditions => { :method => :post }

  # TODO: replace with format.js?
  map.details_table ':controller/:id/details_table',
    :action => 'details_table',
    :conditions => { :method => :get }

  map.resources :expenses,
    :member => { :set_date => :post }

  map.resources :items

  map.resources :categories,
    :collection => { :toplevel => :get },
    :member => { :subcategories => :get }

  map.resources :users

  map.resources :accounts

  map.resources :invitations,
    :member => { :accept => :post }

  map.new_sandbox '/sandbox/new', :controller => 'sandbox_accounts',
    :action => 'new'

  map.namespace :stats do |stats|
    stats.expenses 'expenses', :controller => 'expenses', :action => 'index',
      :conditions => { :method => :get }
    stats.quick 'quick', :controller => 'expenses', :action => 'quick_stats',
      :conditions => { :method => :get }

    stats.resources :categories
  end

  map.resource :settings,
    :member => { :toggle_show_guide => :put }

  map.namespace :settings do |settings|
    settings.resource :email
    settings.resource :password

    settings.resources :other_users, :member => { :remove => :get }
  end

  map.resources :password_reset_requests,
    :member => { :confirm => :get, :fulfill => :put }

  map.about 'about', :controller => 'about', :action => 'index'
  map.namespace :about do |about|
    about.ssl 'ssl', :controller => 'ssl', :action => 'index'
    about.more_ssl 'ssl/more', :controller => 'ssl', :action => 'more'
    about.why_ssl 'ssl/why', :controller => 'ssl', :action => 'why'
    about.accept_ssl 'ssl/accept', :controller => 'ssl', :action => 'accept'
  end

  map.contacts 'about/contacts', :controller => 'about', :action => 'contacts'

  map.dashboard 'dashboard', :controller => 'home', :action => 'dashboard'
  map.language 'language/:id', :controller => 'home', :action => 'language'

  map.testing '__testing', :controller => 'home', :action => 'testing'

  map.root :controller => 'home', :action => 'index'
end
