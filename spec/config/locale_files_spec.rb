# frozen_string_literal: true

require 'rails_helper'
require 'psych'

# Phase 0 fixed four duplicate top-level keys that were silently dropping
# translations, and three more had crept back in by phase 7 - two in
# `forms.labels` and one in `headings`. YAML has no opinion about a repeated
# key: Psych keeps the last one it reads and says nothing, so a duplicate is
# invisible until someone edits the copy that is not in effect and watches the
# change do nothing. Nothing else in the suite would catch that.
RSpec.describe 'the locale files' do
  def duplicate_keys_in(file)
    found = []
    walk(Psych.parse_file(file).root, [], found)
    found
  end

  def walk(node, path, found)
    return unless node.is_a?(Psych::Nodes::Mapping)

    seen = {}
    node.children.each_slice(2) do |key, value|
      here = path + [key.value]
      found << "#{here.join('.')} (lines #{seen[key.value]} and #{key.start_line + 1})" if seen.key?(key.value)
      seen[key.value] = key.start_line + 1
      walk(value, here, found)
    end
  end

  Rails.root.glob('config/locales/*.yml').each do |file|
    context File.basename(file) do
      it 'defines every key exactly once' do
        expect(duplicate_keys_in(file)).to be_empty
      end
    end
  end
end
