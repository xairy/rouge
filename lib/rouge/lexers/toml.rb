module Rouge
  module Lexers
    class TOML < RegexLexer
      desc 'the TOML configuration format (https://github.com/mojombo/toml)'
      tag 'toml'

      filenames '*.toml'
      mimetypes 'text/x-toml'

      def self.analyze_text(text)
        return 0.1 if text =~ /\A\[[\w.]+\]\s*\w+\s*=\s*("\w+")+/
      end

      identifier = /[\w.\S]+/

      state :basic do
        rule /\s+/, 'Text'
        rule /#.*?$/, 'Comment'
        rule /(true|false)/, 'Keyword.Constant'
        rule /(?<!=)\s*\[[\w\d\S]+\]/, 'Name.Namespace'

        rule /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/, 'Literal.Date'

        rule /(\d+\.\d*|\d*\.\d+)([eE][+-]?[0-9]+)?j?/, 'Literal.Number.Float'
        rule /\d+[eE][+-]?[0-9]+j?/, 'Literal.Number.Float'
        rule /\-?\d+/, 'Literal.Number.Integer'
      end

      state :root do
        mixin :basic

        rule /(#{identifier})(\s*)(=)/ do
          group 'Name.Property'; group 'Text'
          group 'Punctuation'
          push :value
        end

      end

      state :value do
        rule /\n/, 'Text', :pop!
        mixin :content
      end

      state :content do
        mixin :basic
        rule /"/, 'Literal.String', :dq
        mixin :esc_str
        rule /\,/, 'Punctuation'
        rule /\[/, 'Punctuation', :array
      end

      state :dq do
        rule /"/, 'Literal.String', :pop!
        mixin :esc_str
        rule /[^\\"]+/, 'Literal.String'
      end

      state :esc_str do
        rule /\\[0t\tn\n "\\ r]/, 'Literal.String.Escape'
      end

      state :array do
        mixin :content
        rule /\]/, 'Punctuation', :pop!
      end
    end
  end
end