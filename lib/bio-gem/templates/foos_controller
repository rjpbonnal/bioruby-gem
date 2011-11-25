class FoosController < ApplicationController
  def example
    @example = Bio::Foo::Example.find(params["id"])
    @examples = Bio::Foo:Example.all
    @togo=TOGOWS.entry('genbank', @example.gene_name)
    @shuttle =  "TEST CASE"
  end

  def index
    @index = "Something relevant"
  end

  def show
    @item = "It's me"
  end

  def new
    @example =  Bio::Foo::Example.new
  end

  def create
    @example = Bio::Foo::Example.new(params[:example])
    if @example.save
      redirect_to example_url(@example)
    else
      # This line overrides the default rendering behavior, which
      # would have been to render the "create" view.
      render :action => "new"
    end
  end
end