-- 동물 보호소에 들어온 동물의 이름은 몇 개인지 조회하는 SQL 문을 작성해주세요. 
-- 이때 이름이 NULL인 경우는 집계하지 않으며 중복되는 이름은 하나로 칩니다.

SELECT COUNT(DISTINCT NAME)
FROM ANIMAL_INS
WHERE NAME IS NOT NULL ---- 이거 없어도 동작함

-- # 몇 '개' -> 집계함수 COUNT
-- # 이름 NULL 미포함, 중복 미포함 
-- # FROM -> WHERE 순으로 읽으니까 WHERE에서 이름 NULL인거 거르고 집계하면 되겠네
-- # 중복 미포함은 SELECT에 DISTINCT 사용하고


============================================================================
----------------------------------- 집계함수 NULL 처리 규칙 ---------------------------------------

WHERE NAME IS NOT NULL 로 이름 NULL인거 거르는 코드 쓰지 않고 SELECT FROM 까지만 적어도 잘 돌아감
집계함수의 NULL 처리 규칙에서
COUNT(컬럼명)은 NULL 제외하고, COUNT(*)은 NULL 포함하기 때문임.
이름이 없는(NULL) 동물은 이름이 아니므로 제외 → COUNT(컬럼명) 사용

참고로 집계함수 COUNT, SUM, MIN, MAX, AVG 에서 COUNT만 * 문법 허용. 나머지는 반드시 컬럼명 작성해야됨
-> 나머지 집계함수 SUM MIN MAX AVG는 당연히 NULL 제외
= COUNT(*) 빼고 나머지 모든 집계함수는 다 NULL 자동 제외

COUNT(*)        → NULL 포함  (행 자체를 카운트)
COUNT(컬럼명)   → NULL 제외
SUM(컬럼명)     → NULL 제외
AVG(컬럼명)     → NULL 제외  (분모에서도 제외)
MAX(컬럼명)     → NULL 제외
MIN(컬럼명)     → NULL 제외