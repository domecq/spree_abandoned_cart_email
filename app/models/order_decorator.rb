Spree::Order.class_eval do

  ABANDONED_EMAIL_TIMEFRAME = 12.hours

  preference :abandedon_email_timeframe, 12.hours

  def self.eligible_abandoned_email_orders
    where("state != ?
            AND payment_state != ?
            AND email is NOT NULL
            AND abandoned_email_sent_at IS NULL
            AND created_at < ?",
          "complete",
          "paid",
          (Time.zone.now - Spree::AbandonedCartEmail::Config.email_timeframe))
  end

  def send_abandoned_email
    # Don't send anything if the order has no line items.
    return if line_items.empty?

    Spree::AbandonedCartMailer.abandoned_email(self).deliver
    mark_abandoned_email_as_sent
  end

  private

  def mark_abandoned_email_as_sent
    update_attribute :abandoned_email_sent_at, Time.zone.now
  end

end
