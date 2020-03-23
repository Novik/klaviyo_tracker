require 'spree_core'
require "klaviyo_tracker/version"
require "klaviyo_tracker/engine"
require 'klaviyo'

module KlaviyoTracker

  extend self

  mattr_accessor :api_key
  @@client = nil

  REASON_MESSAGES = 
  {
    started_checkout: 'Started Checkout',
    placed: 'Placed Order',
    ordered_product: 'Ordered Product',
    cancelled: 'Cancelled Order',
    fulfilled: 'Fulfilled Order'
  }

  def setup
    yield self
  end

  def track(order,reason)
    if REASON_MESSAGES.key?(reason) 
      client.track( REASON_MESSAGES[reason],
#      debug_track( REASON_MESSAGES[reason],
        properties: properties(order),
        customer_properties: customer_properties(order),
        time: order.updated_at
      )
      if reason == :placed 
        order.line_items.map do |li|
          client.track( REASON_MESSAGES[:ordered_product],
#          debug_track( REASON_MESSAGES[reason],
            properties: product_properties(li),
            customer_properties: customer_properties(order),
            time: order.updated_at
          )
        end
      end
    end
  end

  private

  def debug_track( name, options )
    Rails.logger.info "*** Got #{name} with #{options.inspect}"
  end

  def variant_url(v)
    Spree::Core::Engine.routes.url_helpers.method_defined?(:color_product_url) ?
      Spree::Core::Engine.routes.url_helpers.color_product_url(v.product, color: v.options[:color][:slug]) : # our customization
      Spree::Core::Engine.routes.url_helpers.product_url(v.product)
  end

  def variant_image(v)
    img = (v.respond_to?(:color_images) ? v.color_images : v.product.images).try(:first).try(:attachment).try(:url,:large)
    img.present? ? ActionController::Base.helpers.asset_url(img) : nil
  end

  def variant_taxons(v)
    v.product.taxons.map(&:pretty_name).flatten.uniq
  end

  def properties(order)
    {
      "$event_id": order.number,
      "$value": order.total.to_f,
      "Categories": categories_names(order),
      "ItemNames": item_names(order),
      "Items": items(order)
    }
  end

  def product_properties(li)
    line_item_properties(li).merge(
    {
      "$event_id": li.id,
      "$value": li.price.to_f
    })
  end

  def line_item_properties(li)
    {
       "ProductID": li.variant_id,
       "SKU": li.sku,
       "ProductName": li.name,
       "Quantity": li.quantity,
       "ItemPrice": li.price.to_f,
       "ProductURL": variant_url(li.variant),
       "ImageURL": variant_image(li.variant),
       "ProductCategories": variant_taxons(li.variant)
    }
  end

  def customer_properties(order)
    {
      "$email": order.email,
      "$first_name": order.billing_address.first_name,
      "$last_name": order.billing_address.last_name,
      "$phone_number": "+#{order.billing_address.phone.try(:gsub,/[\s\-\+–\(\)]/,'')}",
      "$address1": order.billing_address.address1,
      "$address2": order.billing_address.address2,
      "$city": order.billing_address.city,
      "$zip": order.billing_address.zipcode,
      "$region": order.billing_address.state.try(:name),
      "$country": order.billing_address.country.try(:name)
    }
  end

  def item_names(order)
    order.line_items.map do |li|
      li.name
    end.flatten.uniq
  end

  def categories_names(order)
    order.line_items.map do |li|
      variant_taxons(li.variant)
    end.flatten.uniq
  end

  def items(order)
    order.line_items.map do |li|
      line_item_properties(li)
    end
  end

  def client
    @@client ||= Klaviyo::Client.new(@@api_key)
  end

end