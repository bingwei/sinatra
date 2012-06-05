require File.expand_path('../helper', __FILE__)
require 'wlang'

class WLangTest < Test::Unit::TestCase
  def engine
    Tilt::WLangTemplate
  end

  def wlang_app(&block)
    mock_app {
      set :views, File.dirname(__FILE__) + '/views'
      get '/', &block
    }
    get '/'
  end

  it 'uses the correct engine' do
    assert_equal engine, Tilt[:wlang]
  end

  it 'renders .wlang files in views path' do
    wlang_app { wlang :hello }
    assert ok?
    assert_equal "Hello from wlang!\n", body
  end

  it 'renders in the app instance scope' do
    mock_app do
      helpers do
        def who; "world"; end
      end
      get('/') { wlang 'Hello +{who}!' }
    end
    get '/'
    assert ok?
    assert_equal 'Hello world!', body
  end

  it 'takes a :locals option' do
    wlang_app do
      locals = {:foo => 'Bar'}
      wlang 'Hello ${foo}!', :locals => locals
    end
    assert ok?
    assert_equal 'Hello Bar!', body
  end

  it "renders with inline layouts" do
    mock_app do
      layout { 'THIS. IS. +{yield.upcase}!' }
      get('/') { wlang 'Sparta' }
    end
    get '/'
    assert ok?
    assert_equal 'THIS. IS. SPARTA!', body
  end

  it "renders with file layouts" do
    wlang_app { wlang 'Hello World', :layout => :layout2 }
    assert ok?
    assert_body "WLang Layout!\nHello World"
  end

end