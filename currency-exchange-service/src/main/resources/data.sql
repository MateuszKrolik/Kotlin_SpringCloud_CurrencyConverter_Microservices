CREATE EXTENSION IF NOT EXISTS pgcrypto;
INSERT INTO currency_exchange (id, currency_from, currency_to, conversion_multiple) VALUES
                                                                                        (gen_random_uuid(), 'USD', 'PLN', 3.83),
                                                                                        (gen_random_uuid(), 'EUR', 'PLN', 4.28),
                                                                                        (gen_random_uuid(), 'GBP', 'INR', 5.12);