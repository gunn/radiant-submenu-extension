class SubmenuSitesDataset < Dataset::Base
  
  def load
    create_record Site, :test, :name => 'Test host', :domain => '^test\.', :base_domain => 'test.host', :position => 3
    Page.current_site = sites(:test) if defined? Site
  end
end
