;; clarity_data_registry.clar
;; Data Registry contract for Stacks (Clarity)
;; Features:
;; - Register dataset entries with metadata URI, versioning and owner
;; - Update metadata (owner only)
;; - Transfer ownership
;; - Deactivate / reactivate entries
;; - Read entries by id
;; - Auto-incrementing numeric id
;;
;; Notes:
;; - Metadata is stored as a buffer (e.g. IPFS URI or JSON blob)
;; - This is a simple, auditable registry suitable as a starting point
;;
;; -----------------------------
;; Data structures
;; -----------------------------
(define-map registry
  ;; key
  { id: uint }
  ;; value
  {
    owner: principal,
    metadata: (buff 256),
    version: uint,
    active: bool,
    created: uint,
    updated: uint
  })

(define-data-var next-id uint u1)

;; Error codes
(define-constant ERR-NOT-FOUND u404)
(define-constant ERR-NOT-AUTHORIZED u401)
(define-constant ERR-ALREADY-EXISTS u409)

;; -----------------------------
;; Helpers
;; -----------------------------
(define-read-only (current-block-height)
  ;; return a placeholder timestamp
  u0)

;; internal: fetch entry or return none
(define-read-only (map-get-entry (id uint))
  (map-get? registry { id: id }))

;; -----------------------------
;; Public actions
;; -----------------------------
(define-public (register (metadata (buff 256)) (version uint))
  (let (
        (id (var-get next-id))
        (owner tx-sender)
        (ts (current-block-height)))
    (begin
      ;; ensure not already present (defensive, though next-id prevents collisions)
      (if (is-some (map-get? registry { id: id }))
        (err ERR-ALREADY-EXISTS)
        (begin
          (map-set registry { id: id }
            {
              owner: owner,
              metadata: metadata,
              version: version,
              active: true,
              created: ts,
              updated: ts
            })
          (var-set next-id (+ id u1))
          (ok id))))))

(define-public (update-metadata (id uint) (metadata (buff 256)) (version uint))
  (let ((maybe (map-get? registry { id: id })))
    (match maybe
      entry
      (let ((owner (get owner entry))
            (active (get active entry))
            (created (get created entry))
            (ts (current-block-height)))
        (if (is-eq tx-sender owner)
            (begin
              (map-set registry { id: id }
                {
                  owner: owner,
                  metadata: metadata,
                  version: version,
                  active: active,
                  created: created,
                  updated: ts
                })
              (ok id))
            (err ERR-NOT-AUTHORIZED)))
      (err ERR-NOT-FOUND))))

(define-public (transfer-ownership (id uint) (new-owner principal))
  (let ((maybe (map-get? registry { id: id })))
    (match maybe
      entry
      (let ((owner (get owner entry))
            (metadata (get metadata entry))
            (version (get version entry))
            (active (get active entry))
            (created (get created entry))
            (ts (current-block-height)))
        (if (is-eq tx-sender owner)
            (begin
              (map-set registry { id: id }
                {
                  owner: new-owner,
                  metadata: metadata,
                  version: version,
                  active: active,
                  created: created,
                  updated: ts
                })
              (ok id))
            (err ERR-NOT-AUTHORIZED)))
      (err ERR-NOT-FOUND))))

(define-public (set-active (id uint) (flag bool))
  (let ((maybe (map-get? registry { id: id })))
    (match maybe
      entry
      (let ((owner (get owner entry))
            (metadata (get metadata entry))
            (version (get version entry))
            (created (get created entry))
            (ts (current-block-height)))
        (if (is-eq tx-sender owner)
            (begin
              (map-set registry { id: id }
                {
                  owner: owner,
                  metadata: metadata,
                  version: version,
                  active: flag,
                  created: created,
                  updated: ts
                })
              (ok id))
            (err ERR-NOT-AUTHORIZED)))
      (err ERR-NOT-FOUND))))

;; -----------------------------
;; Read-only views
;; -----------------------------
(define-read-only (get-entry (id uint))
  (match (map-get? registry { id: id })
    entry (ok entry)
    (err ERR-NOT-FOUND)))

(define-read-only (get-next-available-id)
  (ok (var-get next-id)))

;; -----------------------------
;; Admin convenience: delete entry (owner only)
;; -----------------------------
(define-public (delete-entry (id uint))
  (let ((maybe (map-get? registry { id: id })))
    (match maybe
      entry
      (let ((owner (get owner entry)))
        (if (is-eq tx-sender owner)
            (begin
              (map-delete registry { id: id })
              (ok id))
            (err ERR-NOT-AUTHORIZED)))
      (err ERR-NOT-FOUND))))

;; -----------------------------
;; Examples of how to use in Clarinet / unit tests:
;; 1. (contract-call? .registry register "ipfs://..." u1)
;; 2. (contract-call? .registry update-metadata u1 "ipfs://new" u2)
;; 3. (contract-call? .registry transfer-ownership u1 'SP...) 
;; 4. (contract-call? .registry set-active u1 false)
;; 5. (contract-call? .registry get-entry u1)
;; -----------------------------

;; End of contract
