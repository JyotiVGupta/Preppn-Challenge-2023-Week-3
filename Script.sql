** Solution 

* 1. Prepping the Transaction Table

SELECT  SUM (Value) as V1,
                    CASE
                            WHEN online_or_in_person = 2
                                THEN 'In-Person'
                            WHEN online_or_in_person = 1
                                THEN 'Online'
                                    END as online_or_in_person,
                    DATE_PART ('quarter', DATE(LEFT(TRANSACTION_DATE, 10), 'dd/MM/yyyy')) as Q
                        FROM PD2023_WK01
                            WHERE CONTAINS(TRANSACTION_CODE, 'DSB')
                                GROUP BY 2,3
                                ORDER BY  online_or_in_person, Q
                        ;


* 2. Prepping the Target Table

SELECT t.ONLINE_OR_IN_PERSON, REPLACE(Month, 'Q', '')::int as Q, Quarterly_Targets, trans.V1,
                    Trans.V1 - Quarterly_Targets as Var
                        FROM PD2023_WK03_TARGETS as t
                            UNPIVOT (Quarterly_Targets FOR month IN (Q1, Q2, Q3, Q4))
                        ;


* 3. Joining the tables

WITH Trans AS(
                    SELECT  SUM (Value) as V1,
                            CASE
                                WHEN online_or_in_person = 2
                                        THEN 'In-Person'
                                WHEN online_or_in_person = 1
                                        THEN 'Online'
                                            END as online_or_in_person,
                            DATE_PART ('quarter', DATE(LEFT(TRANSACTION_DATE, 10), 'dd/MM/yyyy')) as Q

                                FROM PD2023_WK01
                                        WHERE CONTAINS(TRANSACTION_CODE, 'DSB')
                                            GROUP BY 2,3
                                            ORDER BY  online_or_in_person, Q
        )

                    SELECT t.ONLINE_OR_IN_PERSON, REPLACE(Month, 'Q', '')::int as Q, Quarterly_Targets, trans.V1,
                            Trans.V1 - Quarterly_Targets as Var
                                FROM PD2023_WK03_TARGETS as t
                                    UNPIVOT (Quarterly_Targets FOR month IN (Q1, Q2, Q3, Q4))
                                            JOIN Trans
                                                ON t.ONLINE_OR_IN_PERSON = Trans.online_or_in_person
                                                AND REPLACE(Month, 'Q', '')::int = Q
                                ;