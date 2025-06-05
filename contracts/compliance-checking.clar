;; Compliance Checking Contract
;; Validates payments against compliance rules and regulations

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u300))
(define-constant ERR_AMOUNT_EXCEEDS_LIMIT (err u301))
(define-constant ERR_BLOCKED_COUNTRY (err u302))
(define-constant ERR_BLOCKED_BANK (err u303))
(define-constant ERR_INVALID_AMOUNT (err u304))

;; Compliance limits
(define-data-var daily-limit uint u1000000) ;; $1M in cents
(define-data-var single-transaction-limit uint u100000) ;; $100K in cents

;; Blocked countries
(define-map blocked-countries
  { country: (string-ascii 50) }
  { blocked: bool, reason: (string-ascii 200) }
)

;; Blocked banks
(define-map blocked-banks
  { bank-id: (string-ascii 50) }
  { blocked: bool, reason: (string-ascii 200) }
)

;; Daily transaction tracking
(define-map daily-transactions
  { bank-id: (string-ascii 50), date: uint }
  { total-amount: uint, transaction-count: uint }
)

;; Update compliance limits
(define-public (update-daily-limit (new-limit uint))
  (if (is-eq tx-sender CONTRACT_OWNER)
    (begin
      (var-set daily-limit new-limit)
      (ok true)
    )
    ERR_UNAUTHORIZED
  )
)

(define-public (update-transaction-limit (new-limit uint))
  (if (is-eq tx-sender CONTRACT_OWNER)
    (begin
      (var-set single-transaction-limit new-limit)
      (ok true)
    )
    ERR_UNAUTHORIZED
  )
)

;; Block/unblock country
(define-public (set-country-status (country (string-ascii 50))
                                  (blocked bool)
                                  (reason (string-ascii 200)))
  (if (is-eq tx-sender CONTRACT_OWNER)
    (begin
      (map-set blocked-countries
        { country: country }
        { blocked: blocked, reason: reason }
      )
      (ok true)
    )
    ERR_UNAUTHORIZED
  )
)

;; Block/unblock bank
(define-public (set-bank-status (bank-id (string-ascii 50))
                               (blocked bool)
                               (reason (string-ascii 200)))
  (if (is-eq tx-sender CONTRACT_OWNER)
    (begin
      (map-set blocked-banks
        { bank-id: bank-id }
        { blocked: blocked, reason: reason }
      )
      (ok true)
    )
    ERR_UNAUTHORIZED
  )
)

;; Check payment compliance
(define-public (check-payment-compliance (sender-bank (string-ascii 50))
                                        (receiver-bank (string-ascii 50))
                                        (sender-country (string-ascii 50))
                                        (receiver-country (string-ascii 50))
                                        (amount uint))
  (let ((current-date (/ block-height u144)) ;; Approximate daily blocks
        (sender-daily (default-to { total-amount: u0, transaction-count: u0 }
                                 (map-get? daily-transactions { bank-id: sender-bank, date: current-date }))))

    ;; Check amount validity
    (asserts! (> amount u0) ERR_INVALID_AMOUNT)

    ;; Check single transaction limit
    (asserts! (<= amount (var-get single-transaction-limit)) ERR_AMOUNT_EXCEEDS_LIMIT)

    ;; Check daily limit
    (asserts! (<= (+ (get total-amount sender-daily) amount) (var-get daily-limit)) ERR_AMOUNT_EXCEEDS_LIMIT)

    ;; Check blocked countries
    (asserts! (not (is-country-blocked sender-country)) ERR_BLOCKED_COUNTRY)
    (asserts! (not (is-country-blocked receiver-country)) ERR_BLOCKED_COUNTRY)

    ;; Check blocked banks
    (asserts! (not (is-bank-blocked sender-bank)) ERR_BLOCKED_BANK)
    (asserts! (not (is-bank-blocked receiver-bank)) ERR_BLOCKED_BANK)

    ;; Update daily transaction tracking
    (map-set daily-transactions
      { bank-id: sender-bank, date: current-date }
      {
        total-amount: (+ (get total-amount sender-daily) amount),
        transaction-count: (+ (get transaction-count sender-daily) u1)
      }
    )

    (ok true)
  )
)

;; Helper functions
(define-read-only (is-country-blocked (country (string-ascii 50)))
  (match (map-get? blocked-countries { country: country })
    country-data (get blocked country-data)
    false
  )
)

(define-read-only (is-bank-blocked (bank-id (string-ascii 50)))
  (match (map-get? blocked-banks { bank-id: bank-id })
    bank-data (get blocked bank-data)
    false
  )
)

(define-read-only (get-daily-transactions (bank-id (string-ascii 50)))
  (let ((current-date (/ block-height u144)))
    (map-get? daily-transactions { bank-id: bank-id, date: current-date })
  )
)
