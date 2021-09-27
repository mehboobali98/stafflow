EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\z/.freeze
PASSWORD_LENGTH = (6..128).freeze
VALID_LEAVE_RANGE = (1..40).freeze
LEAVE_COUNT_SCALE = 0.5
PAGE_SIZE = 5
TRUNCATE_LENGTH = 15
DEFAULT_TAX_RATE = 10
DEFAULT_VALUE = '--'
COUNTRIES_LIST = { Austrailia: 'Austrailia', Denmark: 'Denmark', England: 'England', Germany: 'Germany',
                   Netherlands: 'Netherlands', Pakistan: 'Pakistan', Russia: 'Russia' }.freeze
FLOAT_MAX = 99_999_999_999_999_999_999_999
FLOAT_MIN = -99_999_999_999_999_999_999_999
MIN_TAX_RATE = 0
MAX_TAX_RATE = 100
