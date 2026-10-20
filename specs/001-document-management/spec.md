# Feature Specification: Document Upload and Management

**Feature Branch**: Not created; no branch-creation hook is configured.
**Feature Directory**: specs/001-document-management
**Created**: 2026-10-20
**Status**: Draft - ready for planning
**Input**: User description: "--file StakeholderDocs/document-upload-and-management-feature.md"
**Source**: [Stakeholder requirements](../../StakeholderDocs/document-upload-and-management-feature.md)
**Governance**: [ContosoDashboard Constitution v1.0.0](../../.specify/memory/constitution.md)

## Clarifications

### Session 2026-10-20

- Q: When two people change the same document, what happens if the second person tries to save using an outdated version? → A: Option A: reject stale edits, replacements, and deletions; preserve the committed change and require refresh and a new attempt.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Upload and Retrieve My Documents (Priority: P1)

An employee uploads personal work documents or documents for an assigned project, supplies descriptive information, and retrieves accepted documents from My Documents.

**Why this priority**: Secure upload and reliable retrieval provide the smallest useful document-management experience.

**Independent Test**: With a signed-in employee and an operational offline malware-checking capability, upload valid and invalid files, inspect My Documents, and download an accepted file without enabling sharing, search, or reporting.

**Acceptance Scenarios**:

1. **Given** a signed-in employee and a supported, clean file no larger than 25 MB, **When** the employee supplies a title and category and uploads it, **Then** progress is visible, success is confirmed only after the document is retrievable, and My Documents shows its title, category, upload date, size, and project if selected (FR-001 through FR-007, FR-009, FR-017).
2. **Given** multiple selected files, **When** one is valid and others are oversized or unsupported, **Then** the valid file can succeed independently and each rejected file has a specific error without appearing as a completed document (FR-002, FR-004, FR-005, FR-007).
3. **Given** a file with malware or an unavailable malware-checking capability, **When** upload is attempted, **Then** the file is not accepted, stored as an available document, previewed, or shared, and the user receives the reason (FR-006).
4. **Given** an employee who is not a member or manager of a project, **When** the employee attempts to associate an upload with that project, **Then** the association and upload are denied without exposing project documents (FR-010, FR-013).

---

### User Story 2 - Browse and Find Authorized Documents (Priority: P2)

An employee browses personal and project documents, filters and sorts them, searches descriptive information, and previews or downloads an authorized result.

**Why this priority**: Centralization is useful only when employees can quickly find the right document without exposing other people's records.

**Independent Test**: Use pre-existing documents belonging to multiple users and projects to verify browsing, filtering, search, preview, and denial without requiring the upload or sharing workflows.

**Acceptance Scenarios**:

1. **Given** uploaded documents spanning several categories, projects, and dates, **When** the owner filters and sorts My Documents, **Then** the visible records match the selected filters and sort order (FR-017, FR-018).
2. **Given** a project member and a project document, **When** the member opens Project Documents, **Then** the member sees the document and can download it; a nonmember without an independent permission cannot discover or retrieve it (FR-010 through FR-013, FR-019).
3. **Given** a search phrase appearing in a title, description, tag, uploader name, or project name, **When** an employee searches, **Then** matching authorized records appear within 2 seconds and inaccessible records do not appear in results or counts (FR-012, FR-020, SC-003).
4. **Given** an authorized PDF, JPEG, or PNG document, **When** the employee requests preview, **Then** it opens within the browser within 3 seconds; other supported types remain downloadable without a promised preview (FR-021, FR-022, SC-004).
5. **Given** a user whose only project permission was membership, **When** that membership is removed and the user next requests the document, **Then** project-derived access is denied without relying on an old list or notification (FR-012, FR-013).

---

### User Story 3 - Maintain Documents Without Losing Access or Content (Priority: P2)

A document owner updates descriptive information, replaces the current file, or permanently deletes a document after confirmation. Managers use the permissions assigned to their roles.

**Why this priority**: Employees need to keep documents current and remove obsolete material without corrupting existing records or breaking shared references.

**Independent Test**: Start with a document owned by an employee, including a shared reference, and test authorized and denied edits, replacement failures, and confirmed or cancelled deletion independently of new uploads.

**Acceptance Scenarios**:

1. **Given** a document owner, **When** the owner edits its title, description, category, and tags, **Then** valid changes persist and a blank title or missing category is rejected (FR-003, FR-023).
2. **Given** an authorized maintainer, **When** a replacement passes the same file and malware checks as an upload, **Then** the current content changes while document identity, authorized shares, and task references remain intact; a rejected or failed replacement leaves the prior content available (FR-024, FR-025).
3. **Given** a document owner or its project manager, **When** deletion is cancelled, **Then** nothing changes; **When** deletion is confirmed and succeeds, **Then** the content and document listing disappear, prior share and task links no longer retrieve it, and the deletion activity remains auditable (FR-014, FR-026, FR-027, FR-037).
4. **Given** a user outside the document's permitted maintenance roles, **When** the user attempts an edit, replacement, or deletion, **Then** the action is denied and the document is unchanged (FR-012, FR-023 through FR-026).
5. **Given** a Team Lead and a document uploaded by a current member of the lead's department in any category other than Personal Files, **When** the lead views, downloads, edits metadata, replaces the file, or confirms deletion, **Then** the operation is permitted subject to the standard validation and confirmation rules (FR-015, FR-023 through FR-026).
6. **Given** a Team Lead and another department member's Personal Files document with no independent access grant, **When** the lead attempts discovery, viewing, download, metadata editing, replacement, or deletion, **Then** the operation is denied without revealing the document's metadata or content (FR-012, FR-015).
7. **Given** a Personal Files document shared with a Team Lead who has no independent maintenance permission, **When** the lead reads, downloads, or requests a supported preview, **Then** access is permitted through the share, but metadata editing, replacement, and deletion remain denied (FR-015, FR-029).
8. **Given** two authorized maintainers who opened the same document state, **When** one commits a change and the other submits an edit, file replacement, or confirmed deletion based on the older state, **Then** the second operation is rejected without changing the accepted metadata, content, shares, or task references, and the user is asked to refresh and make a new attempt (FR-042).
9. **Given** a replacement still undergoing validation or malware checking, **When** another authorized operation changes or deletes the document before the replacement completes, **Then** the stale replacement cannot overwrite the newer state or recreate a deleted document (FR-024, FR-027, FR-042).
10. **Given** a stale edit whose actor has also lost access to the document, **When** the edit is submitted, **Then** it is denied without exposing the newer metadata or content through a conflict message (FR-012, FR-013, FR-042).

---

### User Story 4 - Share Documents With Colleagues (Priority: P2)

A document owner shares a document with a named colleague or an existing team. Authorized recipients discover it in Shared with Me and receive an in-app notification.

**Why this priority**: Controlled sharing replaces uncontrolled copies while retaining a clear owner and explicit access boundaries.

**Independent Test**: Use an existing document and recipients from two departments to verify direct and team sharing, notifications, recipient access, and denial for everyone else.

**Acceptance Scenarios**:

1. **Given** an owner and an existing colleague, **When** the owner shares the document with that colleague, **Then** the colleague receives a notification and the document appears in Shared with Me with read, preview where supported, and download access, but no editing, deletion, or onward-sharing rights from that share alone (FR-028 through FR-030).
2. **Given** an owner and an existing department team, **When** the owner shares with that team, **Then** its current members can find the document in Shared with Me and receive notifications, while nonmembers without another grant remain denied (FR-011, FR-013, FR-028 through FR-030).
3. **Given** a document already shared with a recipient, **When** the owner repeats the same share, **Then** it remains one effective share and no duplicate share notification is created for that unchanged grant (FR-031).
4. **Given** a user who has only received a share, **When** that user attempts to share with another colleague, **Then** the action is denied (FR-028).

---

### User Story 5 - Use Documents From Tasks and the Dashboard (Priority: P3)

An employee associates authorized documents with tasks, uploads new task-related documents, and sees recent personal activity and project notifications within the existing dashboard.

**Why this priority**: Integration removes the need to leave existing work contexts but depends on the underlying document experience.

**Independent Test**: Use an existing task and authorized documents to test attachment, automatic project association, dashboard summaries, and project notifications without relying on sharing or reports.

**Acceptance Scenarios**:

1. **Given** an authorized project-task user, **When** the user attaches an accessible document or uploads one from task details, **Then** the attachment is associated with the task's project; an inaccessible document or a conflicting project association is rejected (FR-032, FR-033).
2. **Given** a task viewer who lacks access to an attached document, **When** task details are viewed, **Then** the attachment does not expose the document's title, content, or download; task attachment alone grants no document access (FR-012, FR-032).
3. **Given** an employee with more than five accepted uploads, **When** the employee opens the dashboard, **Then** Recent Documents shows the five most recent uploads still available to that employee, and the summary count equals the employee's available uploaded-document total (FR-034, FR-035).
4. **Given** a newly accepted project document, **When** it becomes available, **Then** current project members other than the uploader receive one new-document notification each; rejected uploads produce none (FR-036).

---

### User Story 6 - Audit Document Activity (Priority: P3)

An administrator reviews document activity and reports on uploaded document types, active uploaders, and access patterns while ordinary employees remain unable to view administrative reports.

**Why this priority**: Audit visibility supports the stated oversight needs after the core employee workflows are available.

**Independent Test**: Use a known activity history to compare expected totals and rankings with administrator reports, including activity on deleted documents, and deny access to a nonadministrator.

**Acceptance Scenarios**:

1. **Given** successful uploads, downloads, deletions, and shares, **When** an administrator reviews activity, **Then** each successful action identifies the actor, document, action, and time, including deletion records without retaining deleted file content (FR-037, FR-038).
2. **Given** a known activity set, **When** an administrator generates reports, **Then** document-type counts, uploader rankings, and access frequencies by user, document, and time match the activity set (FR-039, SC-011).
3. **Given** a nonadministrator, **When** administrative activity or report access is attempted, **Then** access is denied (FR-038).
4. **Given** an administrator, **When** the administrator accesses a document, **Then** the administrator has the full document-management permissions stated in FR-016 and relevant activity is recorded.

### Edge Cases

- A file exactly at the 25 MB limit is eligible; an empty file or a file one byte above the limit is rejected. A permitted extension with incompatible detected content is rejected (FR-004, FR-005).
- Missing required information or an unavailable project is reported per file, and correcting one file does not require reselecting already accepted files (FR-002, FR-003, FR-007, FR-010).
- Malware-checking timeout, unavailability, or inconclusive results fail closed; unverified content never becomes available (FR-006).
- Interrupted uploads, insufficient storage, or failed document registration produce no success confirmation or visible completed document. The user can retry; a failed replacement leaves its predecessor intact (FR-007 through FR-009, FR-025).
- Identical filenames or titles from different uploads never overwrite a different document, and unusual filenames cannot select storage locations or expose other content (FR-008).
- An upload interrupted by session expiry cannot complete as an unauthenticated operation; the user is asked to sign in again (FR-001, FR-012).
- Removed project or department membership ends grants derived from that membership on the next access; independent ownership, direct shares, and administrator privileges are evaluated separately (FR-013).
- Changing a category cannot be used to bypass access rules: the actor MUST already have permission before the change. Moving a document into Personal Files removes the Team Lead department-management grant on the next operation; moving it out restores that grant only for leads of the uploader's current department. Independent ownership, project, sharing, and administrator permissions are evaluated separately (FR-012, FR-015).
- A deleted or newly inaccessible document is absent from subsequent search, preview, dashboard, attachment, and shared-document views; stale notifications do not grant access (FR-012, FR-027).
- Cancelled or failed deletion leaves the document unchanged and does not claim permanent removal. Successful deletion retains only the activity evidence, not the file content (FR-026, FR-027, FR-037).
- Concurrent metadata edits, replacements, and deletions MUST NOT silently overwrite accepted changes: only an operation based on the current document state may commit. Stale attempts are rejected, preserve the latest accepted state, and require refresh and an explicit new attempt; an operation against a deleted document MUST NOT recreate it. Current authorization is checked without revealing inaccessible changes (FR-012, FR-042).
- A failed notification does not falsely report delivery or turn a completed upload/share into an apparently missing document; recipients can still discover an effective share or project document through the relevant view (FR-007, FR-019, FR-030, FR-036).
- A task without an associated project accepts personal attachments only when the user can access both the task and document; a cross-project attachment is rejected without silently reassigning an existing document (FR-032, FR-033).
- Empty lists, filters, or searches display a clear no-results state without revealing inaccessible-document counts (FR-012, FR-017 through FR-020).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: All document operations MUST require an existing authenticated dashboard user; unauthenticated users MUST be directed to sign in and MUST receive no document content or metadata.
- **FR-002**: Users MUST be able to select one or multiple files and provide required information per file. Each selected file MUST have an independent validation and completion outcome.
- **FR-003**: Each document MUST have a nonblank title and one category from Project Documents, Team Resources, Personal Files, Reports, Presentations, or Other. Description, custom tags, and associated project MUST be optional except when task context supplies a project.
- **FR-004**: Uploads and replacements MUST accept PDF, Word, Excel, PowerPoint, plain text, JPEG, and PNG documents within the supported formats defined in Assumptions. Unsupported or misrepresented types MUST be rejected with an explanation.
- **FR-005**: Each file MUST be nonempty and no larger than 25 MB, inclusive. Oversized or empty files MUST be rejected with a clear reason and the applicable limit.
- **FR-006**: Every upload and replacement MUST pass actual virus and malware checking before acceptance or retention as a managed document. Detected threats, unavailable checking, errors, and inconclusive results MUST reject the operation; no unchecked file may be made available or silently treated as safe.
- **FR-007**: Users MUST see upload progress and a per-file success or actionable failure outcome. Success MUST mean the document is available through its authorized retrieval workflow, not merely that transfer started.
- **FR-008**: Documents MUST remain distinct even when titles or original filenames match. User-supplied names MUST NOT overwrite another document, select a storage location, or enable access outside authorized documents.
- **FR-009**: Accepted documents MUST retain their title, original filename, description, category, tags, optional project, uploader identity and displayed name, original upload date/time, file size, and file type. Partial failures MUST NOT leave an apparently completed document without retrievable content.
- **FR-010**: Employees MUST be able to upload personal documents and upload to projects they currently belong to or manage. Project association MUST NOT be permitted solely because a user knows a project identifier.
- **FR-011**: Document read/download access MUST be granted through ownership, current project membership or management, an explicit direct/team share, an applicable Team Lead permission under FR-015, or administrator status. A category name alone MUST NOT grant access.
- **FR-012**: Authorization MUST apply on every document listing, search, preview, download, attachment, mutation, share, and administrative operation. Denied users MUST NOT obtain content, descriptive metadata, or existence/count information about unauthorized documents by guessing a reference or following an old link.
- **FR-013**: Membership- and role-derived permissions MUST reflect current membership/role at the next operation. Removal MUST end the corresponding grant, while independent ownership, explicit direct sharing, or administrator grants remain independently evaluated.
- **FR-014**: A Project Manager MUST be able to view, download, edit descriptive metadata, replace, and delete documents associated with projects that manager currently manages.
- **FR-015**: A Team Lead MUST be able to view, download, edit descriptive metadata, replace, and delete documents uploaded by current members of the lead's department in every category except Personal Files. The Team Lead role alone MUST NOT grant discovery, read, preview, download, or maintenance access to another user's Personal Files document. Independent permissions from ownership, project membership or management, explicit sharing, or administrator status MUST still apply within their respective scopes; a share alone remains read-only under FR-029. The current category MUST be evaluated on every operation, including after a category change, and the change itself MUST require existing metadata-edit permission.
- **FR-016**: Administrators MUST have access to all documents for viewing, download, supported preview, metadata maintenance, replacement, deletion, and sharing, as well as administrative audit and reports.
- **FR-017**: My Documents MUST list the user's own currently accessible uploaded documents and display title, category, upload date, size, and associated project where present.
- **FR-018**: My Documents MUST support ascending/descending sorting by title, original upload date, category, and file size, and combined filtering by category, project, and inclusive upload-date range.
- **FR-019**: Project Documents MUST show authorized documents associated with the selected project and allow all current project members and its manager to read/download them. It MUST NOT expose unrelated personal documents.
- **FR-020**: Search MUST support title, description, tags, uploader name, and project name across documents the requester can access, case-insensitively, with partial-text matching and combined filters where offered. No-match results MUST be explicit.
- **FR-021**: Any user with document read permission MUST be able to download its current content using a recognizable filename without receiving permission to edit or reshare from that read grant alone.
- **FR-022**: Authorized users MUST be able to preview PDF, JPEG, and PNG documents within the browser. Other supported documents MUST remain downloadable without a requirement for preview or conversion.
- **FR-023**: Owners MUST be able to edit title, description, category, and tags; managers and administrators MUST be limited to their scopes in FR-014 through FR-016. These edits MUST preserve document identity, original uploader, upload time, project association, shares, and task links.
- **FR-024**: Authorized maintainers MUST be able to replace the current file after the same size, type, malware, and permission checks used for upload. Replacement MUST update current file properties and preserve document identity, descriptive information, shares, and task links; no previous-version retrieval is required.
- **FR-025**: A rejected, interrupted, or failed replacement MUST preserve the previously accepted file and its current metadata rather than leave an inaccessible or partially replaced document.
- **FR-026**: Owners, applicable managers, and administrators MUST explicitly confirm permanent deletion. Cancellation or failure MUST NOT claim success or change the existing document; recipients with only a share MUST NOT delete it.
- **FR-027**: Successful deletion MUST remove file content and its document listing, invalidate shares and task references, and prevent subsequent retrieval through old links. Audit evidence MUST remain, without retaining the deleted file content or offering recovery.
- **FR-028**: Owners and administrators MUST be able to grant read/download and supported-preview access to specific existing users or department teams. Project membership or receipt of a share alone MUST NOT authorize onward sharing.
- **FR-029**: A direct or team share MUST NOT grant metadata editing, replacement, deletion, or onward sharing; recipients may still have separate permissions from ownership or their applicable role.
- **FR-030**: Effective shared documents MUST appear in each authorized recipient's Shared with Me view, and newly granted recipients other than the actor MUST receive an in-app notification identifying the document and sharer.
- **FR-031**: Repeating an unchanged share MUST NOT create duplicate effective shares or duplicate share notifications for the same grant.
- **FR-032**: Task users MUST be able to see and attach related documents only when authorized for both task and document. Attaching MUST NOT expand document access for task viewers or allow a document from a conflicting project.
- **FR-033**: Task details MUST allow uploading a new related document using the standard upload checks. A task's project MUST be associated automatically; a task without a project MUST leave the new document personal.
- **FR-034**: The dashboard MUST show up to five of the current user's most recent accepted uploads, newest first, excluding deleted or inaccessible documents. Replacement MUST NOT change the original upload ordering.
- **FR-035**: The dashboard MUST show the count of the current user's own available uploaded documents, consistent with My Documents, rather than a global count.
- **FR-036**: A newly accepted project upload MUST notify current members of that project other than the uploader once each. Rejected uploads MUST NOT produce new-document notifications.
- **FR-037**: Successful uploads, downloads, deletions, and shares MUST produce an activity record identifying actor, document reference, action, and time. Deletion MUST preserve enough evidence for reporting without preserving deleted content.
- **FR-038**: Only administrators MUST be able to inspect the administrative activity history and generate document-activity reports; ordinary document access MUST NOT grant report access.
- **FR-039**: Administrator reports MUST summarize upload counts by file type, upload counts/rankings by uploader, and document access frequencies by document, user, and time based on recorded activities, including historical activity for deleted documents.
- **FR-040**: Core document workflows, including required malware checking, MUST be usable in a prepared local training environment without an internet connection, cloud account, or external service. They MUST use existing dashboard identities, role/project boundaries, and in-app notifications, and MUST remain explicitly training-only.
- **FR-041**: The feature MUST distinguish empty/no-result states, validation errors, access denial, and operational failures through clear user-facing outcomes without exposing unauthorized document details.
- **FR-042**: Metadata edits, file replacements, and confirmed deletions MUST be based on the current document state when committed. If another operation has changed or deleted that state since it was obtained for the attempted mutation, the system MUST reject the stale attempt without changing or recreating the latest accepted document state. An authorized user MUST receive a conflict outcome requesting refresh and an explicit new attempt, not silent overwrite or automatic replay. Permission checks MUST use current authorization and MUST NOT expose inaccessible metadata or content through conflict handling. Replacement validation or malware checking MUST NOT allow an older state to overwrite a later committed change.

### Key Entities *(include if feature involves data)*

- **Document**: One managed work document with stable identity, original uploader and upload time, current file, original/display filename, size, type, title, description, category, optional tags, and optional project.
- **Document State**: The current accepted metadata and file for a document. Edits, replacements, and deletions are tied to the state on which the user acted; a competing committed change makes that earlier state stale without creating user-visible version history (FR-042).
- **Category**: One of the six named organizational categories; not an independent grant of access.
- **Document Share**: An explicit read-only grant from an owner or administrator to a named user or department team for one document.
- **User and Team**: Existing dashboard identities and roles; a team is the user's current department for sharing and Team Lead scope.
- **Project**: Existing work context whose current membership and manager confer scoped document access.
- **Task Attachment**: Association between a document and an existing task that preserves the document's access boundary and project consistency.
- **Document Activity**: A historical successful action with actor, document reference, action, and time; retained after document deletion without retaining file content.
- **Notification**: An existing in-app message about a newly granted share or a newly available project document, subject to current authorization when followed.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In each agreed acceptance run, a clean supported file up to 25 MB becomes available to its uploader within 30 seconds, measured from upload submission through required checking and retrieval availability in the prepared training environment.
- **SC-002**: In each acceptance run with up to 500 authorized documents, employees see the requested document list and its sort/filter result within 2 seconds.
- **SC-003**: In each acceptance run with up to 500 authorized documents, employees receive authorized search results or an explicit no-results outcome within 2 seconds.
- **SC-004**: Authorized PDF and image previews become visible within 3 seconds in each acceptance run.
- **SC-005**: A familiar employee can submit a single-file upload in no more than three activation clicks from the documents view, excluding typing metadata and interacting with the operating system's file picker. Required metadata is still supplied.
- **SC-006**: Every file in a mixed acceptance upload selection has one clear terminal success/failure outcome, and every accepted file is retrievable with unchanged content; no failed file appears as a completed document.
- **SC-007**: The complete acceptance set rejects every oversized, unsupported, malicious, or unverified file, and rejects all unauthorized discovery, read, edit, replacement, deletion, attachment, sharing, and report attempts for the agreed role matrix.
- **SC-008**: In an agreed employee evaluation, users can upload, find, and retrieve their document without assistance, and every participant can correctly identify which selected files succeeded or failed from the displayed outcomes.
- **SC-009**: Within three months of a representative rollout or training pilot, at least 70% of active dashboard users have uploaded a document, mean document-finding time is under 30 seconds, and at least 90% of sampled uploads have the business-appropriate category rather than merely a nonempty category.
- **SC-010**: No confirmed unauthorized document access incidents occur during the three-month pilot; passing training checks MUST NOT be presented as production certification.
- **SC-011**: Administrator report counts and rankings agree exactly with a known acceptance activity set for uploads, downloads, deletions, and shares, including deleted-document history.
- **SC-012**: All core acceptance workflows pass with the training environment disconnected from the internet after initial preparation, without requiring a cloud account.
- **SC-013**: In acceptance cases pairing metadata edits, file replacements, and confirmed deletions against the same initial document state, no stale attempt succeeds after a competing change commits. The newer accepted state remains intact, deleted documents are not recreated, and authorized users receive a refresh-and-retry outcome without silently losing accepted changes.

### Assumptions and Dependencies

- The constitution governs conflicts: the stakeholder's 8-10 week target is a training-delivery planning target, not a commitment to production readiness. Identity hardening, production deployment, and cloud migration are separate future work.
- Existing signed-in users, roles, project/task membership, and in-app notifications are available. Existing departments are the team grouping; no new organization hierarchy or team-administration feature is introduced. Missing department membership gives no department-derived grant.
- "Manage" means read/download, supported preview, metadata edit, replacement, and confirmed deletion within the role's scope; sharing grants are reserved to owners and administrators. Clarification Q1, answered on 2026-10-20 with option B: Team Lead department-management permission excludes Personal Files; independent ownership, project, explicit-share, and administrator permissions are not revoked by this exception (FR-015).
- Initial supported extensions are .pdf, .doc, .docx, .xls, .xlsx, .ppt, .pptx, .txt, .jpg, .jpeg, and .png, with matching file content. Other formats, including macro-enabled Office extensions, are not implicitly accepted.
- For unambiguous boundary testing, the displayed 25 MB limit means 26,214,400 bytes. The range starts at one byte. This defines a per-file limit, not a new storage quota.
- Local disk capacity and an operational, genuine offline malware-checking capability with appropriately maintained detection data are training prerequisites. No mock pass result satisfies FR-006; absence blocks uploads/replacements. Temporary handling for checking MUST NOT make a file a retained, retrievable managed document before it passes.
- Performance is measured in a documented representative training setup, with clean supported files, warmed-up application, usable local storage, and the normal connection between user and application. Upload timing includes file transfer and malware checking; preparation is excluded. Hardware, connectivity, and concurrent workload are recorded with results rather than assumed to support an unstated employee count.
- No initial concurrent-user or global document-volume commitment is inferred. The 500-document list target is applied to the search acceptance dataset as a conservative common test baseline.
- Department-share access follows current department membership, while notifications are sent to members at grant time; joining a department later does not require retroactive notifications. Project upload notifications similarly use membership at upload time.
- Removed memberships invalidate only their derived grants, not independent ownership or direct sharing. Moving between projects, reassignment of ownership, share-revocation controls, and version history are not inferred as initial workflows.
- The dashboard count is personal and consistent with My Documents. A file replacement retains the original upload time; activity history can record the replacement separately without creating user-visible version history.
- Active users for the pilot are users who sign in during its three-month measurement window. Adoption counts distinct such users with at least one successful upload during that window. Category correctness is reviewed against document purpose; finding time is measured from opening the document experience to identifying the target document.
- Implementation constraints and detailed guidance remain in the linked stakeholder source and constitution for planning. This specification does not select storage mechanisms, programming interfaces, schema representation, or UI component patterns, and authorizes no destructive data-reset commands.

### Out of Scope

- Production deployment or production-security certification, cloud migration, cloud services, and external document-system integrations.
- Real-time collaborative editing, version history/rollback, approval/routing workflows, and advanced document automation.
- Native mobile applications, document templates/generation, storage quotas, and soft delete/trash/recovery.
- Office-document preview/conversion, arbitrary extra file formats, ownership transfer, project reassignment of existing documents, and new team-management screens.
- Separate share-revocation workflows beyond removal of current role/membership grants or document deletion.