# frozen_string_literal: true

# This initializer prevents constant redefinition warnings from payment gateway gems
# by ensuring that constants are only defined once.

# For SpreeStripe::PaymentDecorator
module SpreeStripe
  module PaymentDecorator
    unless defined?(AVS_CODES)
      AVS_CODES = {
        'A' => 'Street address matches, but postal code does not match.',
        'B' => 'Street address matches, but postal code not verified.',
        'C' => 'Street address and postal code do not match.',
        'D' => 'Street address and postal code match. ',
        'E' => 'AVS data is invalid or AVS is not allowed for this card type.',
        'F' => 'Card member\'s name does not match, but billing postal code matches.',
        'G' => 'Non-U.S. issuing bank does not support AVS.',
        'H' => 'Card member\'s name does not match. Street address and postal code match.',
        'I' => 'Address not verified.',
        'J' => 'Card member\'s name, billing address, and postal code match.',
        'K' => 'Card member\'s name matches but billing address and billing postal code do not match.',
        'L' => 'Card member\'s name and billing postal code match, but billing address does not match.',
        'M' => 'Street address and postal code match. ',
        'N' => 'Street address and postal code do not match.',
        'O' => 'Card member\'s name and billing address match, but billing postal code does not match.',
        'P' => 'Postal code matches, but street address not verified.',
        'Q' => 'Card member\'s name, billing address, and postal code match.',
        'R' => 'System unavailable.',
        'S' => 'Bank does not support AVS.',
        'T' => 'Card member\'s name does not match, but street address matches.',
        'U' => 'Address information unavailable.',
        'V' => 'Card member\'s name, billing address, and billing postal code match.',
        'W' => 'Street address does not match, but 9-digit postal code matches.',
        'X' => 'Street address and 9-digit postal code match.',
        'Y' => 'Street address and 5-digit postal code match.',
        'Z' => 'Street address does not match, but 5-digit postal code matches.'
      }.freeze
    end

    unless defined?(CVV_CODES)
      CVV_CODES = {
        'D' => 'Suspicious transaction',
        'I' => 'Failed data validation check',
        'M' => 'Match',
        'N' => 'No Match',
        'P' => 'Not Processed',
        'S' => 'Should have been present',
        'U' => 'Issuer unable to process request',
        'X' => 'Card does not support verification'
      }.freeze
    end
  end
end

# For SpreeStripe::PaymentMethodDecorator
module SpreeStripe
  module PaymentMethodDecorator
    unless defined?(STRIPE_TYPE)
      STRIPE_TYPE = 'Spree::PaymentMethod::StripeCreditCard'.freeze
    end
  end
end

# For SpreePaypalCheckout::PaymentMethodDecorator
module SpreePaypalCheckout
  module PaymentMethodDecorator
    unless defined?(PAYPAL_CHECKOUT_TYPE)
      PAYPAL_CHECKOUT_TYPE = 'Spree::PaymentMethod::PaypalCheckout'.freeze
    end
  end
end