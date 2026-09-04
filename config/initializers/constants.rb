# frozen_string_literal: true

EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\.[a-z]{2,}\z/i
PASSWORD_LENGTH = (6..128)
MIN_LEAVE_COUNT = 0
MAX_LEAVE_COUNT = 40
LEAVE_COUNT_SCALE = 0.5
PAGE_SIZE = 5
TRUNCATE_LENGTH = 15
DEFAULT_TAX_RATE = 10
DEFAULT_VALUE = '--'
COUNTRIES_LIST = { Austrailia: 'Austrailia', Denmark: 'Denmark', England: 'England', Germany: 'Germany',
                   Netherlands: 'Netherlands', Pakistan: 'Pakistan', Russia: 'Russia' }.freeze
# The money columns are decimal(15, 2). A bound above what the column holds
# does not reject anything - it hands the value to MySQL, which raises out of
# range instead of the model reporting an invalid amount. These are the largest
# magnitudes that still fit.
AMOUNT_MAX = 10_000_000_000_000
AMOUNT_MIN = -10_000_000_000_000
MIN_TAX_RATE = 0
MAX_TAX_RATE = 100
