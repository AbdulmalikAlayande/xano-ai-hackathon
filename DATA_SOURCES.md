# Data Sources Reference

This document lists all official sources used to collect fee information for the Nigerian Government Fees API. All data has been sourced from official government websites and documents to ensure accuracy and credibility.

**Last Updated:** December 2024

---

## Identity & Management

### National Identification Number (NIN) Fees

- **Agency:** National Identity Management Commission (NIMC)
- **Source Document:** SERVICE_LEVEL_AGREEMENT_2025_.pdf
- **URL:** https://nimc.gov.ng
- **Date Accessed:** December 2024
- **Data Collected:**
  - NIN enrollment fees (first-time and modifications)
  - NIN slip replacement fees
  - NIN data correction fees
  - Attestation letter fees
  - Diaspora NIN fees (USD)

**Notes:** Official NIMC SLA document containing NIN modification fees.

---

## Immigration

### Nigerian Passport Fees

- **Agency:** Nigerian Immigration Service (NIS)
- **Source Document:** SERVICE_LEVEL_AGREEMENT_2025_.pdf (NIS section)
- **URL:** https://immigration.gov.ng
- **Date Accessed:** December 2024
- **Data Collected:**
  - Standard passport fees (32-page and 64-page, 5-year and 10-year validity)
  - Diaspora passport fees (USD)
  - Passport data correction fees
  - ECOWAS Travel Certificate fees
  - Contactless biometric passport fees

**Notes:** Passport issuance/renewal fees sourced from NIS section of the SLA.

---

## Education

### NECO Examination Fees

- **Agency:** National Examinations Council (NECO)
- **Source Document:** neco_fees_list
- **URL:** https://neco.gov.ng/exams
- **Date Accessed:** December 2024
- **Data Collected:**
  - SSCE Internal registration and fees
  - SSCE External registration and fees
  - BECE (Basic Education Certificate Examination) fees
  - NCEE (National Common Entrance Examination) fees
  - NGE (National Gifted Examination) fees
  - Late registration fees
  - Result checker tokens
  - Certificate collection fees
  - Remarking fees
  - Accreditation fees

**Notes:** SSCE Internal, SSCE External, BECE, NCEE, NGE, and Other Fees from NECO official website.

### JAMB Fees

- **Agency:** Joint Admissions and Matriculation Board (JAMB)
- **Source Document:** jamb_payment_services
- **URL:** https://www.jamb.gov.ng/payment-Services
- **Date Accessed:** December 2024
- **Data Collected:**
  - UTME registration fees
  - UTME de-registration fees
  - Open University registration fees
  - Distance Learning registration fees
  - Sandwich program registration fees
  - Part-time registration fees
  - Data correction fees (institution, course, name, DOB, state/LGA, gender, A-level qualification)
  - JAMB result slip fees
  - Registration number retrieval fees
  - JAMB admission letter fees
  - Condonement of illegal admission fees
  - Application for transfer fees
  - Change of admission letter fees
  - Fresh admission letter fees

**Notes:** All JAMB payment services and fees sourced from official JAMB portal.

### University Fees (Example: UNILAG)

- **Agency:** University of Lagos (UNILAG)
- **Source Document:** unilag_accepance_page
- **URL:** https://acedhars.unilag.edu.ng/?page_id=154
- **Date Accessed:** December 2024
- **Data Collected:**
  - Acceptance fees
  - Postgraduate fees
  - Various university service fees

**Notes:** Official UNILAG acceptance and postgraduate fee breakdown.

---

## Electricity & Utilities

### Electricity Tariffs

- **Agency:** EKEDC (Ikeja Electric) / Nigerian Electricity Regulatory Commission (NERC)
- **Source Document:** ekedc_tariff_page
- **URL:** https://ekedp.com/tariff-plans
- **Date Accessed:** December 2024
- **Data Collected:**
  - Band A tariff (per kWh)
  - Band B tariff (per kWh)
  - Band C tariff (per kWh)
  - Band D tariff (per kWh)
  - Band E tariff (per kWh)

**Notes:** Official tariff plan page used for electricity tariff categorizations. Tariffs are NERC-approved rates.

---

## Data Collection Methodology

All fee information was collected from official government sources to ensure accuracy:

1. **Primary Sources:** Official government websites and published documents
2. **Verification:** Cross-referenced with multiple official sources where available
3. **Currency:** Fees are listed in their original currency (NGN for most, USD for diaspora services)
4. **Updates:** Data reflects fees as of December 2024

## Data Categories

The API organizes fees into the following categories:

1. **Identity & Management** - NIN and identity-related services
2. **Immigration** - Passport and visa services
3. **Education** - Examination and educational service fees
4. **Electricity & Utilities** - Electricity tariffs and utility charges
5. **Business & Legal** - Corporate and government service fees
6. **Transport & Vehicle Services** - Driver licensing and related fees

## Agency Information

### National Identity Management Commission (NIMC)
- **Website:** https://nimc.gov.ng
- **Role:** Handles NIN issuance and modifications
- **Services:** NIN enrollment, modifications, replacements, attestation letters

### Nigerian Immigration Service (NIS)
- **Website:** https://immigration.gov.ng
- **Role:** Handles passports and visas
- **Services:** Passport issuance, renewals, data corrections, ECOWAS travel certificates

### National Examinations Council (NECO)
- **Website:** https://neco.gov.ng
- **Role:** Conducts SSCE, BECE, NCEE exams
- **Services:** Examination registration, result services, certificate collection

### Joint Admissions and Matriculation Board (JAMB)
- **Website:** https://jamb.gov.ng
- **Role:** Conducts UTME and DE admissions
- **Services:** UTME registration, admission services, data corrections

### Nigerian Electricity Regulatory Commission (NERC)
- **Website:** https://nerc.gov.ng
- **Role:** Regulates electricity tariffs
- **Services:** Electricity tariff regulation and approval

### Federal Ministry of Power
- **Website:** https://power.gov.ng
- **Role:** Supervises electricity sector
- **Services:** Electricity sector oversight

---

## Disclaimer

While every effort has been made to ensure the accuracy of fee information, fees may change without notice. Users should verify current fees with the respective government agencies before making payments. This API serves as a reference guide and should not be the sole source for fee verification.

## Updates

This API is updated periodically to reflect changes in government fees. The `last_database_update` timestamp in the `/metadata` endpoint indicates when the database was last updated.

---

**For questions or corrections regarding data sources, please contact the API maintainers.**

