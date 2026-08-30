# frozen_string_literal: true

# WCAG contrast, measured against what the browser actually computed rather
# than against what the stylesheet says. Tokens compose - a colour set on a
# parent, an alpha, a Bootstrap default winning a specificity fight - so the
# only trustworthy source is the rendered page.
module ContrastHelpers
  # Reports the computed colour, the nearest painted background, and the type
  # size for each selector. Background has to be walked up the tree because an
  # element that sets no background of its own is painted by an ancestor.
  COMPUTED_STYLES = <<~JS
    (function (selectors) {
      var painted = function (node) {
        while (node && node !== document.documentElement) {
          var colour = getComputedStyle(node).backgroundColor;
          if (colour && colour !== 'rgba(0, 0, 0, 0)' && colour !== 'transparent') return colour;
          node = node.parentElement;
        }
        return 'rgb(255, 255, 255)';
      };
      return selectors.map(function (selector) {
        var node = document.querySelector(selector);
        if (!node) return null;
        var style = getComputedStyle(node);
        return {
          selector: selector,
          color: style.color,
          background: painted(node),
          size: parseFloat(style.fontSize),
          weight: parseInt(style.fontWeight, 10)
        };
      });
    })(%<selectors>s)
  JS

  def computed_styles(selectors)
    page.evaluate_script(format(COMPUTED_STYLES, selectors: selectors.inspect))
  end

  # 3:1 for large text, 4.5:1 otherwise - WCAG 2.1 AA.
  def required_ratio(style)
    large = style['size'] >= 24 || (style['size'] >= 18.66 && style['weight'] >= 700)
    large ? 3.0 : 4.5
  end

  def contrast_ratio(foreground, background)
    lit = relative_luminance(flatten(foreground, background))
    unlit = relative_luminance(parse(background).first)
    high, low = lit > unlit ? [lit, unlit] : [unlit, lit]
    (((high + 0.05) / (low + 0.05)) * 100).floor / 100.0
  end

  private

  def parse(colour)
    numbers = colour.scan(/[\d.]+/).map(&:to_f)
    [numbers[0, 3], numbers[3] || 1.0]
  end

  # A translucent foreground is only as readable as what shows through it.
  def flatten(foreground, background)
    fore, alpha = parse(foreground)
    back, = parse(background)
    fore.each_with_index.map { |channel, i| (channel * alpha) + (back[i] * (1 - alpha)) }
  end

  def relative_luminance(rgb)
    red, green, blue = rgb.map { |channel| linearise(channel / 255.0) }
    (0.2126 * red) + (0.7152 * green) + (0.0722 * blue)
  end

  def linearise(channel)
    channel <= 0.03928 ? channel / 12.92 : (((channel + 0.055) / 1.055)**2.4)
  end
end
