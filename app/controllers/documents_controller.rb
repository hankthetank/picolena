class DocumentsController < ApplicationController  
  before_filter :check_if_valid_link, :only=> :download
  
  # Actually doesn't check anything at all. Just a redirect to show_document(query)
  #
  # FIXME: remove this useless action, and go directly from submit button to GET :action => show
  def check_query
    redirect_to :action=>'show', :id=>params[:query]
  end
  
  
  # Show the matching documents for a given query
  #
  # FIXME: should not initialize a finder twice.
  def show
    start=Time.now
      @query=[params[:id],params.delete(:format)].compact.join('.')
      finder=Finder.new(@query)
      finder.execute!
      @pager=::Paginator.new(finder.total_hits,10) do |offset, per_page|
        #FIXME: Shouldn't use a new finder.
        Finder.new(@query,offset,per_page).matching_documents
      end
      @matching_documents=@pager.page(params[:page])
      @total_hits=finder.total_hits
    @time_needed=Time.now-start
  end
  
  
  # Download the file whose md5 path's checksum is given.
  # If the checksum is incorrect, redirect to documents_url via no_valid_link
  def download
    send_file @document.complete_path  
  end
  
  private
  
  def check_if_valid_link
    md5_hash=params[:id]
    no_valid_link unless md5_hash=~/^[a-z0-9]{32}$/ && @document=Finder.new("md5:"<<md5_hash).matching_documents.first
  end
  
  def no_valid_link
    flash[:warning]="no valid link"
    redirect_to documents_url
    return false
  end
end