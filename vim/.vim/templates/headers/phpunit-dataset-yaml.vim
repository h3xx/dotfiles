" vi: sw=2 sts=2 ts=2 et

" For YAML datasets
" Only really useful at G2Planet

insert
address:
  -
    address_id: 114619
    city: Miami
    state: Florida
  -
    address_id: 114598
    city: Miami
    state: Florida

company:
  -
    company_id: 16
    company_type:
    company_name: Test Company
    phone:
    fax:
    email:
    website:
    is_customer: t
    is_active: t

event:
  -
    event_id: 538
    event_name: 'Dummy Event'
    event_code: dummy01
    event_type: Webinar
    address_id: 114619
    start_date: '2015-09-20'
    end_date: '2015-09-22'
    timezone: America/New_York
  -
    event_id: 539
    event_name: 'Dummy Event'
    event_code: dummy02
    event_type: Tradeshow
    address_id: 114598
    start_date: '2015-11-20'
    end_date: '2015-11-22'
    timezone: America/New_York
.
-1
