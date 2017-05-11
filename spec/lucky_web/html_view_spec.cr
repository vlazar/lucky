require "../../spec_helper"

class TestRender < LuckyWeb::HTMLView
  def render
    renders_complicated_html
  end

  private def renders_complicated_html
    header({class: "header"}) do
      text "my text"
      h1 "h1"
      br
      br({class: "br"})
      br class: "br"
      img({src: "src"})
      h2 "A bit smaller", {class: "peculiar"}
      h6 class: "h6" do
        small "super tiny", class: "so-small"
        span "wow"
      end
    end
  end
end

class UnsafePage < LuckyWeb::HTMLView
  def render
    text "<script>not safe</span>"
  end
end

describe LuckyWeb::HTMLView do
  describe "tags that contain contents" do
    it "can be called with various arguments" do
      view.header("text").to_s.should eq %(<header>text</header>)
      view.header("text", {class: "stuff"}).to_s.should eq %(<header class="stuff">text</header>)
      view.header("text", class: "stuff").to_s.should eq %(<header class="stuff">text</header>)
    end
  end

  describe "empty tags" do
    it "can be called with various arguments" do
      view.br.to_s.should eq %(<br/>)
      view.img(src: "my_src").to_s.should eq %(<img src="my_src"/>)
      view.img({src: "my_src"}).to_s.should eq %(<img src="my_src"/>)
      view.img({:src => "my_src"}).to_s.should eq %(<img src="my_src"/>)
    end
  end

  describe "HTML escaping" do
    it "escapes text" do
      UnsafePage.new.render.to_s.should eq "&lt;script&gt;not safe&lt;/span&gt;"
    end

    it "escapes HTML attributes" do
      unsafe = "<span>bad news</span>"
      escaped = "&lt;span&gt;bad news&lt;/span&gt;"
      view.img(src: unsafe).to_s.should eq %(<img src="#{escaped}"/>)
      view.img({src: unsafe}).to_s.should eq %(<img src="#{escaped}"/>)
      view.img({:src => unsafe}).to_s.should eq %(<img src="#{escaped}"/>)
    end
  end

  it "renders complicated HTML syntax" do
    view.render.to_s.should be_a(String)
  end
end

private def view
  TestRender.new
end