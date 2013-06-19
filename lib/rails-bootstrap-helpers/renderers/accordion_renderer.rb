module RailsBootstrapHelpers::Renderers
  class AccordionRenderer < Renderer
    def initialize (template, id, &block)
      super template
      @id = id
      @block = block
      @selector = Selector.new
    end

    def render
      @context = AccordionContext.new(self)
      block.call(context)
      build_accordion
    end

  private
    attr_reader :id
    attr_reader :block
    attr_reader :selector
    attr_reader :context

    def build_accordion
      content_tag :div, id: id, class: "accordion" do
        contents = []
        selector.base "##{id}.accordion" do |base|
          context.each_with_index do |(heading_block, body_block), count|
            contents << build_group(heading_block, body_block, count, base)
          end
        end

        contents.join("\n").html_safe
      end
    end

    def build_group (heading_block, body_block, count, accordion_base)
      base = "accordion-group"

      selector.base ".#{base}" do |group_base|
        foobar = self
        content_tag(:div, class: base) do
          build_heading(heading_block, count, accordion_base, group_base) +
          build_body(body_block)
        end
      end
    end

    def build_heading (block, count, accordion_base, group_base)
      href = "#{group_base}:nth-child(#{count + 1}) .accordion-body.collapse"

      content_tag :div, class: "accordion-heading" do
        content_tag :a,
          href: href,
          class: "accordion-toggle",
          :"data-toggle" => "collapse",
          :"data-parent" => accordion_base,
          &block
      end
    end
    
    def build_body (block)
      content_tag :div, class: 'accordion-body collapse' do
        content_tag :div, class: "accordion-inner", &block if block
      end
    end

    class AccordionContext
      include Enumerable

      def initialize (renderer)
        @renderer = renderer
        @headings = []
        @bodies = []
      end

      def heading(&block)
        @headings << block
      end

      def body(&block)
        @bodies << block
      end

      def each
        @headings.each_with_index do |heading, index|
          yield heading, @bodies[index]
        end
      end
    end

    class Selector
      def initialize
        @base = []
      end

      def base (base, &block)
        @base << base
        block.call @base.join(" ")
      ensure
        @base.pop
      end
    end
  end
end