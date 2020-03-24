Spree::Order.class_eval do

  state_machine do
    before_transition to: [:address,:delivery,:payment,:confirm,:complete], do: :track_started_checkout
    after_transition to: :complete, do: :track_placed_order
    after_transition to: :canceled, do: :track_cancelled_order
  end

  def track_started_checkout(t)
    KlaviyoTracker::track(self,:started_checkout) if user.present?
  end

  def track_placed_order
    KlaviyoTracker::track(self,:placed) if user.present?
  end

  def track_cancelled_order
    KlaviyoTracker::track(self,:cancelled) if user.present?
  end

end
