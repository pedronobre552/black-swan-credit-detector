create or replace view credit_health as
select `bb`.`SK_ID_BUREAU` AS `SK_ID_BUREAU`,
       max((case when (`bb`.`STATUS` in ('c', 'x')) then 0 else cast(`bb`.`STATUS` as unsigned) end)) AS `credit_health`
from `case_study_import`.`bureau_balance` `bb`
group by `bb`.`SK_ID_BUREAU`;

create or replace view case_study_import.feat_bureau_agg as
select `b`.`SK_ID_CURR`                               AS `SK_ID_CURR`,
       coalesce(max(`b`.`AMT_CREDIT_MAX_OVERDUE`), 0) AS `max_overdue`,
       max(`b`.`DAYS_ENDDATE_FACT`)                   AS `days_since_completed`,
       coalesce(sum(`b`.`CNT_CREDIT_PROLONG`), 0)     AS `num_credit_prolong`,
       coalesce(sum(`b`.`AMT_CREDIT_SUM`), 0)         AS `total_credit`,
       coalesce(sum(`b`.`AMT_CREDIT_SUM_DEBT`), 0)    AS `total_debt`,
       coalesce(sum(`b`.`AMT_CREDIT_SUM_LIMIT`), 0)   AS `credit_card_limit`,
       coalesce(sum(`b`.`AMT_CREDIT_SUM_OVERDUE`), 0) AS `total_overdue`
from `case_study_import`.`bureau` `b`
group by `b`.`SK_ID_CURR`;


create or replace view case_study_import.feat_credit_card as
select `case_study_import`.`credit_card_balance`.`SK_ID_CURR`                                          AS `SK_ID_CURR`,
       avg(`case_study_import`.`credit_card_balance`.`AMT_BALANCE`)                                    AS `avg_card_balance`,
       max(`case_study_import`.`credit_card_balance`.`AMT_BALANCE`)                                    AS `max_card_balance`,
       min(`case_study_import`.`credit_card_balance`.`AMT_BALANCE`)                                    AS `min_card_balance`,
       avg(`case_study_import`.`credit_card_balance`.`AMT_CREDIT_LIMIT_ACTUAL`)                        AS `avg_card_limit`,
       max(`case_study_import`.`credit_card_balance`.`AMT_CREDIT_LIMIT_ACTUAL`)                        AS `max_card_limit`,
       min(`case_study_import`.`credit_card_balance`.`AMT_CREDIT_LIMIT_ACTUAL`)                        AS `min_card_limit`,
       avg((`case_study_import`.`credit_card_balance`.`AMT_BALANCE` /
            nullif(`case_study_import`.`credit_card_balance`.`AMT_CREDIT_LIMIT_ACTUAL`,
                   0)))                                                                                AS `credit_ratio`,
       avg(`case_study_import`.`credit_card_balance`.`AMT_DRAWINGS_CURRENT`)                           AS `avg_amt_drawings`,
       max(`case_study_import`.`credit_card_balance`.`AMT_DRAWINGS_CURRENT`)                           AS `max_amt_drawings`,
       sum(`case_study_import`.`credit_card_balance`.`AMT_DRAWINGS_CURRENT`)                           AS `total_amt_drawings`,
       avg(`case_study_import`.`credit_card_balance`.`AMT_DRAWINGS_ATM_CURRENT`)                       AS `avg_amt_atm_drawings`,
       max(`case_study_import`.`credit_card_balance`.`AMT_DRAWINGS_ATM_CURRENT`)                       AS `max_amt_atm_drawings`,
       sum(`case_study_import`.`credit_card_balance`.`AMT_DRAWINGS_ATM_CURRENT`)                       AS `total_amt_atm_drawings`,
       sum(`case_study_import`.`credit_card_balance`.`AMT_PAYMENT_TOTAL_CURRENT`)                      AS `total_paid`,
       sum((case
                when (`case_study_import`.`credit_card_balance`.`AMT_PAYMENT_TOTAL_CURRENT` <
                      `case_study_import`.`credit_card_balance`.`AMT_INST_MIN_REGULARITY`) then 1
                else 0 end))                                                                           AS `amt_times_underpaid`,
       avg(`case_study_import`.`credit_card_balance`.`AMT_TOTAL_RECEIVABLE`)                           AS `avg_receivable`,
       sum((`case_study_import`.`credit_card_balance`.`AMT_TOTAL_RECEIVABLE` -
            `case_study_import`.`credit_card_balance`.`AMT_RECEIVABLE_PRINCIPAL`))                     AS `amt_interest_receivable`,
       sum(`case_study_import`.`credit_card_balance`.`CNT_DRAWINGS_CURRENT`)                           AS `total_drawings`,
       sum(`case_study_import`.`credit_card_balance`.`CNT_DRAWINGS_ATM_CURRENT`)                       AS `total_atm_drawings`,
       (sum(`case_study_import`.`credit_card_balance`.`AMT_DRAWINGS_CURRENT`) /
        nullif(sum(`case_study_import`.`credit_card_balance`.`CNT_DRAWINGS_CURRENT`),
               0))                                                                                     AS `amt_per_drawing`,
       max(`case_study_import`.`credit_card_balance`.`CNT_INSTALMENT_MATURE_CUM`)                      AS `total_paid_instalment`,
       sum((case
                when (`case_study_import`.`credit_card_balance`.`NAME_CONTRACT_STATUS` = 'Active') then 1
                else 0 end))                                                                           AS `cnt_active_months`,
       sum((case
                when (`case_study_import`.`credit_card_balance`.`NAME_CONTRACT_STATUS` = 'Signed') then 1
                else 0 end))                                                                           AS `cnt_signed_months`,
       sum((case
                when (`case_study_import`.`credit_card_balance`.`NAME_CONTRACT_STATUS` in ('Completed', 'Approved'))
                    then 1
                else 0 end))                                                                           AS `cnt_months_neutral`,
       sum((case
                when (`case_study_import`.`credit_card_balance`.`NAME_CONTRACT_STATUS` = 'Demand') then 1
                else 0 end))                                                                           AS `cnt_demand_months`,
       sum((case
                when (`case_study_import`.`credit_card_balance`.`NAME_CONTRACT_STATUS` = 'Refused') then 1
                else 0 end))                                                                           AS `cnt_refused_months`,
       max(`case_study_import`.`credit_card_balance`.`SK_DPD_DEF`)                                     AS `max_dpd`,
       sum(`case_study_import`.`credit_card_balance`.`SK_DPD_DEF`)                                     AS `total_dpd`,
       sum((case
                when (`case_study_import`.`credit_card_balance`.`SK_DPD_DEF` > 0) then 1
                else 0 end))                                                                           AS `cnt_pd_months`
from `case_study_import`.`credit_card_balance`
group by `case_study_import`.`credit_card_balance`.`SK_ID_CURR`;

create or replace view case_study_import.feat_installments_payments as
select `case_study_import`.`installments_payments`.`SK_ID_CURR`                          AS `SK_ID_CURR`,
       max(`case_study_import`.`installments_payments`.`NUM_INSTALMENT_VERSION`)         AS `max_instalment_version`,
       max(`case_study_import`.`installments_payments`.`NUM_INSTALMENT_NUMBER`)          AS `max_instalment_number`,
       max(greatest((`case_study_import`.`installments_payments`.`DAYS_ENTRY_PAYMENT` -
                     `case_study_import`.`installments_payments`.`DAYS_INSTALMENT`), 0)) AS `max_instalment_overdue`,
       max((`case_study_import`.`installments_payments`.`AMT_INSTALMENT` -
            `case_study_import`.`installments_payments`.`AMT_PAYMENT`))                  AS `max_instalment_underpayment`
from `case_study_import`.`installments_payments`
where (`case_study_import`.`installments_payments`.`NUM_INSTALMENT_VERSION` > 0)
group by `case_study_import`.`installments_payments`.`SK_ID_CURR`;

create or replace view case_study_import.feat_pos_cash as
select `t1`.`SK_ID_CURR`                                                           AS `SK_ID_CURR`,
       sum(`t1`.`CNT_INSTALMENT_FUTURE`)                                           AS `cnt_instalment_future_pos`,
       sum((case when (`t1`.`NAME_CONTRACT_STATUS` = 'Active') then 1 else 0 end)) AS `cnt_active_contract_pos`,
       max(`t1`.`SK_DPD_DEF`)                                                      AS `max_dpd_pos`
from (`case_study_import`.`POS_CASH_balance` `t1` join (select `case_study_import`.`POS_CASH_balance`.`SK_ID_PREV`          AS `SK_ID_PREV`,
                                                               max(`case_study_import`.`POS_CASH_balance`.`MONTHS_BALANCE`) AS `max_months`
                                                        from `case_study_import`.`POS_CASH_balance`
                                                        group by `case_study_import`.`POS_CASH_balance`.`SK_ID_PREV`) `t2`
      on (((`t1`.`SK_ID_PREV` = `t2`.`SK_ID_PREV`) and (`t1`.`MONTHS_BALANCE` = `t2`.`max_months`))))
group by `t1`.`SK_ID_CURR`;


create or replace view case_study_import.feat_prev_application as
select `case_study_import`.`previous_application`.`SK_ID_CURR`                        AS `SK_ID_CURR`,
       sum((case
                when (`case_study_import`.`previous_application`.`NAME_CONTRACT_STATUS` = 'Approved') then 1
                else 0 end))                                                          AS `prev_cnt_approved`,
       sum((case
                when (`case_study_import`.`previous_application`.`NAME_CONTRACT_STATUS` = 'Refused') then 1
                else 0 end))                                                          AS `prev_cnt_refused`,
       (sum((case
                 when (`case_study_import`.`previous_application`.`NAME_CONTRACT_STATUS` = 'Approved') then 1.0
                 else 0.0 end)) / nullif(count(0), 0))                                AS `prev_approval_rate`,
       avg((`case_study_import`.`previous_application`.`AMT_CREDIT` /
            nullif(`case_study_import`.`previous_application`.`AMT_APPLICATION`, 0))) AS `prev_avg_loan_grant_ratio`,
       avg(`case_study_import`.`previous_application`.`AMT_APPLICATION`)              AS `prev_avg_amount_asked`,
       max(`case_study_import`.`previous_application`.`DAYS_DECISION`)                AS `prev_days_last_decision`,
       sum((case
                when (`case_study_import`.`previous_application`.`NAME_CONTRACT_TYPE` = 'Cash loans') then 1
                else 0 end))                                                          AS `prev_cnt_cash_loans`,
       sum((case
                when (`case_study_import`.`previous_application`.`NAME_CONTRACT_TYPE` = 'Consumer loans') then 1
                else 0 end))                                                          AS `prev_cnt_consumer_loans`,
       avg(`case_study_import`.`previous_application`.`NFLAG_INSURED_ON_APPROVAL`)    AS `prev_avg_insurance_uptake`
from `case_study_import`.`previous_application`
group by `case_study_import`.`previous_application`.`SK_ID_CURR`;

create or replace view risk_level as
select
    b.SK_ID_CURR,
    max(ch.credit_health) as max_risk_level,
    avg(ch.credit_health) as  avg_risk_level,
    count(ch.credit_health) as num_credits
FROM bureau as b left join credit_health as ch USING(SK_ID_BUREAU)
group by b.SK_ID_CURR;

create table feat_bureau_tab as
select * from feat_bureau_agg;

create table feat_credit_card_tab as
select * from feat_credit_card;

create table feat_installments_tab as
select * from feat_installments_payments;

create table feat_pos_cash_tab as
select * from feat_pos_cash;

create table feat_prev_application_tab as
select * from feat_prev_application;

create table risk_level_tab as
select * from risk_level;


create table final_test as
select * from
    case_study_import.application_test as at
        left join feat_bureau_tab  USING (SK_ID_CURR)
        left join feat_credit_card_tab   USING (SK_ID_CURR)
        left join feat_installments_tab  USING (SK_ID_CURR)
        left join feat_pos_cash_tab USING (SK_ID_CURR)
        left join feat_prev_application_tab  USING (SK_ID_CURR)
        left join risk_level_tab  USING (SK_ID_CURR);

create table final_train as
select * from
    case_study_import.application_train as at
        left join feat_bureau_tab  USING (SK_ID_CURR)
        left join feat_credit_card_tab   USING (SK_ID_CURR)
        left join feat_installments_tab  USING (SK_ID_CURR)
        left join feat_pos_cash_tab USING (SK_ID_CURR)
        left join feat_prev_application_tab  USING (SK_ID_CURR)
        left join risk_level_tab  USING (SK_ID_CURR);

