Spree::Shipment.class_eval do

  state_machine do
    after_transition to: :shipped, do: :track_fulfilled_order
  end

  def track_fulfilled_order
    KlaviyoTracker::track(order,:fulfilled) if order.try(:user).present?
  end

end
