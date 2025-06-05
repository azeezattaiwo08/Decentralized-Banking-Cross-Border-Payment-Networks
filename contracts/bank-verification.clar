;; Bank Verification Contract
;; Manages registration and verification of banking institutions

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_BANK_EXISTS (err u101))
(define-constant ERR_BANK_NOT_FOUND (err u102))
(define-constant ERR_INVALID_STATUS (err u103))

;; Bank status types
(define-constant STATUS_PENDING u0)
(define-constant STATUS_VERIFIED u1)
(define-constant STATUS_SUSPENDED u2)

;; Bank data structure
(define-map banks
  { bank-id: (string-ascii 50) }
  {
    name: (string-ascii 100),
    country: (string-ascii 50),
    swift-code: (string-ascii 11),
    status: uint,
    registered-at: uint,
    verified-at: (optional uint)
  }
)

;; Bank registration by bank ID
(define-map bank-principals
  { principal: principal }
  { bank-id: (string-ascii 50) }
)

;; Register a new bank
(define-public (register-bank (bank-id (string-ascii 50))
                             (name (string-ascii 100))
                             (country (string-ascii 50))
                             (swift-code (string-ascii 11)))
  (let ((existing-bank (map-get? banks { bank-id: bank-id })))
    (if (is-some existing-bank)
      ERR_BANK_EXISTS
      (begin
        (map-set banks
          { bank-id: bank-id }
          {
            name: name,
            country: country,
            swift-code: swift-code,
            status: STATUS_PENDING,
            registered-at: block-height,
            verified-at: none
          }
        )
        (map-set bank-principals
          { principal: tx-sender }
          { bank-id: bank-id }
        )
        (ok bank-id)
      )
    )
  )
)

;; Verify a bank (only contract owner)
(define-public (verify-bank (bank-id (string-ascii 50)))
  (if (is-eq tx-sender CONTRACT_OWNER)
    (let ((bank-data (map-get? banks { bank-id: bank-id })))
      (if (is-some bank-data)
        (begin
          (map-set banks
            { bank-id: bank-id }
            (merge (unwrap-panic bank-data) { status: STATUS_VERIFIED, verified-at: (some block-height) })
          )
          (ok true)
        )
        ERR_BANK_NOT_FOUND
      )
    )
    ERR_UNAUTHORIZED
  )
)

;; Get bank information
(define-read-only (get-bank (bank-id (string-ascii 50)))
  (map-get? banks { bank-id: bank-id })
)

;; Check if bank is verified
(define-read-only (is-bank-verified (bank-id (string-ascii 50)))
  (match (map-get? banks { bank-id: bank-id })
    bank-data (is-eq (get status bank-data) STATUS_VERIFIED)
    false
  )
)

;; Get bank ID by principal
(define-read-only (get-bank-by-principal (principal principal))
  (map-get? bank-principals { principal: principal })
)
