# CPAD Assignment Report - Cross Platform E-Commerce App (Scoped)

## Student / Group Details

- Group ID: `<TO_BE_FILLED>`
- Submission file name placeholder: `CPAD_Assignment_<Group_ID>.zip`

## 1. Problem Statement

Design a cross-platform e-commerce application that supports:
- Login screen
- Dashboard with product listing and search
- Product detail page

## 2. Scope Definition

### 2.1 In Scope

- Customer authentication using email and password
- Product browsing and text-based search
- Product detail viewing
- Web + mobile frontend support through Flutter
- Backend service using REST APIs
- SQL-based persistence

### 2.2 Out of Scope

- Cart and checkout
- Payment processing
- Address and shipping
- Order tracking and returns
- Multi-role workflows (admin/seller/delivery)

## 3. Logical Architecture

The solution uses a 5-layer logical architecture:

1. Presentation Layer (Flutter UI for Web/Mobile)
2. Application Layer (Use-case orchestration)
3. Domain Layer (Core business rules)
4. Infrastructure Layer (Repository implementations, security)
5. Data Layer (SQL schema and constraints)

Detailed architecture responsibilities are documented in `logical_architecture.md`.

### 3.1 Architecture Justification

- Supports separation of concerns
- Enables maintainability and easier testing
- Keeps business logic decoupled from UI and data access
- Supports multi-client delivery (web and mobile)

### 3.2 Layer Interaction Summary

- UI requests handled by Application services
- Application services invoke Domain entities/rules
- Data access through repository interfaces and infrastructure implementations
- SQL DB stores normalized data

## 4. ER Model

The ER model is intentionally minimal and aligned to the approved scope.

Entities:
- Customer
- Product
- LoginSession

Relationships:
- Customer (1) -> (0..*) LoginSession

Detailed ER documentation is in `er_model.md`.

## 5. UML Artifacts

### 5.1 UML Package Diagram

- Source: `diagrams/uml_package_diagram.puml`
- Image: `diagrams/uml_package_diagram.png`

### 5.2 ER Diagram

- Source: `diagrams/erd.puml`
- Image: `diagrams/erd.png`

## 6. Compliance with Evaluation Rubric

### 6.1 Logical Architecture (3%)

- Layers identified clearly
- Responsibilities for each layer documented
- Component interactions explained
- Separation of concerns explicitly maintained
- UML package diagram provided

### 6.2 Demo (5%)

- Demo video to be created separately by student/group
- Suggested flow: login -> search product -> open detail page

### 6.3 Documentation Quality (2%)

- Scope boundaries are explicit
- Architecture and ER model are concise and complete for required features
- In-scope/out-of-scope boundaries documented

## 7. References

1. Larman, Requirements and Architecture references (provided in course material)
2. Applying UML and Patterns (provided in course material)
3. Visual Paradigm: What is Entity Relationship Diagram
4. Open Text BC: Entity Relationship Model

## 8. Conclusion

The proposed architecture and ER model satisfy the assignment requirements for a scoped e-commerce app focused on login, dashboard listing with search, and product detail viewing, while preserving extensibility for future modules such as cart and order management.
