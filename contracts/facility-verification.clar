;; Facility Verification Contract
;; Validates legitimate production sites

(define-data-var admin principal tx-sender)

;; Data map to store verified facilities
(define-map verified-facilities
  { facility-id: (string-ascii 32) }
  {
    owner: principal,
    name: (string-ascii 100),
    location: (string-ascii 100),
    verified: bool,
    verification-date: uint
  }
)

;; Public function to register a new facility
(define-public (register-facility (facility-id (string-ascii 32)) (name (string-ascii 100)) (location (string-ascii 100)))
  (let
    ((caller tx-sender))
    (asserts! (not (is-facility-registered facility-id)) (err u1))
    (ok (map-set verified-facilities
      { facility-id: facility-id }
      {
        owner: caller,
        name: name,
        location: location,
        verified: false,
        verification-date: u0
      }
    ))
  )
)

;; Admin function to verify a facility
(define-public (verify-facility (facility-id (string-ascii 32)))
  (let
    ((caller tx-sender))
    (asserts! (is-eq caller (var-get admin)) (err u2))
    (asserts! (is-facility-registered facility-id) (err u3))
    (ok (map-set verified-facilities
      { facility-id: facility-id }
      (merge (unwrap-panic (map-get? verified-facilities { facility-id: facility-id }))
        {
          verified: true,
          verification-date: block-height
        }
      )
    ))
  )
)

;; Read-only function to check if a facility is registered
(define-read-only (is-facility-registered (facility-id (string-ascii 32)))
  (is-some (map-get? verified-facilities { facility-id: facility-id }))
)

;; Read-only function to check if a facility is verified
(define-read-only (is-facility-verified (facility-id (string-ascii 32)))
  (default-to false (get verified (map-get? verified-facilities { facility-id: facility-id })))
)

;; Read-only function to get facility details
(define-read-only (get-facility-details (facility-id (string-ascii 32)))
  (map-get? verified-facilities { facility-id: facility-id })
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (let
    ((caller tx-sender))
    (asserts! (is-eq caller (var-get admin)) (err u4))
    (ok (var-set admin new-admin))
  )
)
