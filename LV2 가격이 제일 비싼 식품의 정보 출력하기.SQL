-- FOOD_PRODUCT 테이블에서 가격이 제일 비싼 식품의 
-- 식품 ID, 식품 이름, 식품 코드, 식품분류, 식품 가격을 조회하는 SQL문을 작성해주세요.

-- 1. 서브쿼리 작성 - 동점자(같은 최고가)가 여러 개면 전부 나옴 — 실무에서 안전한 방법
SELECT PRODUCT_ID, PRODUCT_NAME, PRODUCT_CD, CATEGORY, PRICE
FROM FOOD_PRODUCT
WHERE PRICE = (SELECT MAX(PRICE) FROM FOOD_PRODUCT)

-- 2. ORDER BY + LIMIT — 가장 짧음 ⚠️ 동점자가 있으면 1개만 나옴 (문제 조건 잘 확인)
SELECT PRODUCT_ID, PRODUCT_NAME, PRODUCT_CD, CATEGORY, PRICE
FROM FOOD_PRODUCT
ORDER BY PRICE DESC
LIMIT 1

-- 3. RANK() 윈도우 함수 — 가장 명확하지만 코드가 길어짐
SELECT PRODUCT_ID, PRODUCT_NAME, PRODUCT_CD, CATEGORY, PRICE
FROM (SELECT PRODUCT_ID, PRODUCT_NAME, PRODUCT_CD, CATEGORY, PRICE,
      RANK() OVER (ORDER BY PRICE DESC) AS RNK
     FROM FOOD_PRODUCT) AS RANKED
WHERE RNK = 1



==============================================================================
==============================================================================
------------------------------------- 집계함수 및 GROUP BY -----------------------------------

집계함수(Aggregate Function) - 원칙적으로 GROUP BY 필요함
★  多행 -> 1행 으로 줄여버림 (SUM, COUNT, AVG, MIN, MAX)  ★
✅ GROUP BY 없어도 되는 경우 — 테이블 전체를 하나로 집계
-- 테이블 전체에서 최솟값/최댓값 하나만 뽑을 때
SELECT MIN(price), MAX(price) FROM products;
-- 결과: 행 1개
✅ GROUP BY 필요한 경우 — 그룹별로 나눠서 집계, 집계함수 아닌 일반 컬럼이 SELECT에 존재
-- 카테고리별 최저가/최고가
SELECT category
     , MIN(price) AS 최저가
     , MAX(price) AS 최고가
FROM products
GROUP BY category;  -- 이게 없으면 에러
★ category처럼 집계함수가 아닌 일반 컬럼이 SELECT에 있으면 반드시 GROUP BY에 명시해야 함 ★
products 테이블
| category | price |
|----------|-------|
| 전자     | 1000  |
| 전자     | 2000  |
| 식품     | 500   |
| 식품     | 300   |
GROUP BY category 없이 SELECT category, MIN(price) 하면?
→ DB 입장: "MIN(price)는 300인데, category는 어느 행 걸 보여줘?"
→ 답 못 함 → 에러

집계함수 사용 가능 위치:
SELECT ✅  FROM ✅  WHERE ❌  HAVING ✅  ORDER BY ✅

==============================================================================
------------------------------- 윈도우함수 (집계함수와 비교하며 이해 - 집계함수보다 더 좁은 사용처) ---------------------------------

윈도우 함수도 집계함수와 마찬가지로 WHERE 절에서 사용 불가 (실행순서 문제 - '윈도우 함수는 반드시 SELECT 단계에서 계산'되기 때문)
윈도우함수의 작동 원리 : "전체 행을 다 확정한 뒤" 각 행에 값을 붙이는 방식. 행이 확정되기 전에는 순위를 매길 수 없음.
-- WHERE 단계 → 필터링으로 행 확정
--                     ↓
-- SELECT 단계 → 확정된 행 전체를 보면서 RANK() 계산
SELECT / ORDER BY 에서만 윈도우함수 사용 가능 (SQL 실행순서 참고 -> 5. SELECT 6. ORDER BY 임. SELECT단계 전까지는 존재 불가)
서브쿼리로 윈도우함수 넣으려면 반드시 FROM 절 내부에 서브쿼리로 넣는 것만 가능 (또는 CTE로 FROM 서브쿼리 효과내기)
윈도우 함수 사용 가능 위치 (진짜 이거말고는 없다):
SELECT ✅  FROM ❌  WHERE ❌  HAVING ❌  ORDER BY ✅ + FROM 절 서브쿼리 

-- 집계함수는 여러 행 → 1개 행으로 줄임.
-- 윈도우 함수는 여러 행 → 행 수 유지 하면서 각 행에 계산값(순위/누계 등) 추가.
집계함수 (GROUP BY)        윈도우 함수
| category | AVG(price) |  | name | price | RANK |
|----------|------------|  |------|-------|------|
| 전자     | 5000       |  | A    | 9000  |  1   |
| 식품     | 3000       |  | B    | 5000  |  2   |
                           | C    | 3000  |  3   |
행이 줄어듦 ❌             행 수 유지 ✅

윈도우 함수 트리거
"~별 순위"
"~순으로 N번째"
"전체 대비 각 행의 ~"
"누적 합계"
"이전/다음 행 값"
"그룹 내 순위"
순위, N번째 -> RANK(), DENSE_RANK(), ROW_NUMBER()
누적 합계   -> SUM() OVER()
이전 행 값  -> LAG()
다음 행 값  -> LEAD()


RANK 함수 -> 동점이면 같은 순위, 다음 순위는 건너뜀 (1,1,3,4...)
기본 문법 -- OVER() — 윈도우 함수의 필수 키워드, 없으면 에러
RANK() OVER (
    PARTITION BY 그룹기준컬럼   -- (선택) 그룹 나누기 (GROUP BY 처럼. 없으면 전체 테이블 순위)
    ORDER BY 정렬기준컬럼 DESC  -- (필수) 순위 기준
)
-- PARTITION BY 없을 때 — 전체 순위
SELECT FOOD_NAME
     , PRICE
     , RANK() OVER (ORDER BY PRICE DESC) AS RNK
FROM FOOD_PRODUCT;
| FOOD_NAME | PRICE | RNK |
|-----------|-------|-----|
| 과자A     | 9000  |  1  |
| 음료B     | 9000  |  1  |  ← 동점 → 같은 순위
| 식품C     | 5000  |  3  |  ← 2는 건너뜀
| 식품D     | 3000  |  4  |
-- PARTITION BY 있을 때 — 그룹별 순위
SELECT FOOD_NAME
     , FOOD_CLASS
     , PRICE
     , RANK() OVER (
         PARTITION BY FOOD_CLASS   -- 분류별로 나눠서
         ORDER BY PRICE DESC       -- 각 분류 안에서 순위
       ) AS RNK
FROM FOOD_PRODUCT;
| FOOD_NAME | FOOD_CLASS | PRICE | RNK |
|-----------|------------|-------|-----|
| 과자A     | 과자       | 9000  |  1  |  ← 과자 안에서 1위
| 과자B     | 과자       | 5000  |  2  |  ← 과자 안에서 2위
| 음료A     | 음료       | 7000  |  1  |  ← 음료 안에서 1위 (리셋)
| 음료B     | 음료       | 3000  |  2  |  ← 음료 안에서 2위

-- RANK vs DENSE_RANK vs ROW_NUMBER
| NAME | PRICE | RANK | DENSE_RANK | ROW_NUMBER |
|------|-------|------|------------|------------|
| A    | 9000  |  1   |     1      |     1      |
| B    | 9000  |  1   |     1      |     2      |  ← 동점 처리 (같은 순위 VS 순서대로)
| C    | 5000  |  3   |     2      |     3      |  ← 건너뜀 vs 안건너뜀
| D    | 3000  |  4   |     3      |     4      |

==============================================================================
------------------------------- 서브쿼리 조건 / 위치 별 정리 + CTE ---------------------------------

★ 서브쿼리 위치 별 정리 ★
SELECT (스칼라 서브쿼리) 조건: 반드시 단일 값(1행 1열) 반환 -- 2행 이상 반환하면 에러 / 주요 용도 : 각 행에 단일값 추가
FROM   (인라인 뷰)      조건: 테이블처럼 생긴 결과면 다 가능 (행/열 제한 없음), 별칭 없으면 에러 -- 주요 용도 : 윈도우함수 필터, 복잡한 중간 결과
WHERE  (중첩 서브쿼리)  조건: 단일 값(1행 1열. = 사용) or 목록(여러 행, 1열. IN, EXISTS 사용) 반환 -- 2열 이상 반환하면 에러 / 주요 용도 : 집계값 비교, ID 목록 필터
HAVING (중첩 서브쿼리)  조건: WHERE절과 동일 (단일값 or 목록) -- 주요 용도 : 집계 결과와 집계값 비교

 ★ WHERE 에서 목록이 테이블 형태(여러행 + 1열) = 개별 문자열('A','B','C') 구성이 아니라 통문자열 구성('A,B,C')이면
 IN, EXISTS 쓰는게 아니라 LIKE, FIND_IN_SET 써야됨. 통문자열 굳이 'A','B','C'처럼 쪼개서 IN 가능하지만 비추 ★
 IN, EXISTS   → 행으로 나눠진 목록에 사용 ✅ 정확한 이해
 LIKE         → 통문자열 포함 여부 검색   ✅ 정확한 이해

① SELECT절 — 스칼라 서브쿼리 -- 조건: 반드시 단일 값(1행 1열) 반환
SELECT FOOD_NAME
     , PRICE
     , (SELECT AVG(PRICE) FROM FOOD_PRODUCT) AS 전체평균  -- 단일값 ✅
FROM FOOD_PRODUCT;
| FOOD_NAME | PRICE | 전체평균 |
|-----------|-------|---------|
| 과자A     | 9000  |  5000   |
| 음료B     | 3000  |  5000   |  ← 모든 행에 동일한 단일값 붙음
③ WHERE절 — 중첩 서브쿼리 -- 조건: 단일 값(1행 1열. = 사용) or 목록(여러 행, 1열. IN, EXISTS 사용) 반환 
-- 단일값 반환 → = 연산자
WHERE PRICE = (SELECT MAX(PRICE) FROM FOOD_PRODUCT)
-- 목록 반환 → IN 연산자
WHERE FOOD_ID IN (SELECT FOOD_ID FROM FOOD_PRODUCT WHERE PRICE > 5000)
-- 존재 여부 → EXISTS
WHERE EXISTS (SELECT 1 FROM ORDERS WHERE ORDERS.FOOD_ID = FOOD_PRODUCT.FOOD_ID)
-- ❌ 안되는 경우 — 윈도우 함수 (테이블이 나와버림) --- 윈도우함수는 무조건 FROM 서브쿼리 or CTE
WHERE (SELECT RANK() OVER (...)) = 1
④ HAVING절 — 중첩 서브쿼리 -- 조건: WHERE절과 동일 (단일값 or 목록), 집계 이후 단계라는 점만 다름
SELECT FOOD_CLASS
     , AVG(PRICE)
FROM FOOD_PRODUCT
GROUP BY FOOD_CLASS
HAVING AVG(PRICE) > (SELECT AVG(PRICE) FROM FOOD_PRODUCT);  -- 전체 평균보다 높은 그룹

서브쿼리 위치별 트리거
위치         트리거                                     키워드예시
SELECT   "각 행마다 ~값 함께 출력"                       각 상품 가격과 전체 평균 같이 보기, 각 직원의 급여와 부서 평균 급여를 같이
FROM     "윈도우 함수" "중간 결과를 테이블 -> 다시 조건"   순위 매긴 후 N등만 뽑기, 카테고리별 평균 구하고 → 그 중 평균 5000 이상만, 월별 매출 구하고 → 상위 3개월만
WHERE    "가장 ~한 것" "~와 같은" "~목록에 속하는"        최고가 상품, 주문된 적 있는 상품만, 전체 평균보다 비싼 상품, 주문 테이블에 존재하는 고객만
HAVING   "그룹 집계값이 전체 평균보다 ~"                  평균 이상인 그룹만, 카테고리 평균가격이 전체 평균보다 높은 카테고리만, 주문 건수가 평균 주문 건수보다 많은 고객
① SELECT절 — "각 행마다 비교값 함께 보고 싶을 때"
② FROM절 — "중간 가공이 필요할 때"
③ WHERE절 — "조건의 기준값이 고정이 아닐 때"
④ HAVING절 — "그룹 집계값을 전체 집계값과 비교할 때"


CTE 설명 -- "변수 따로 빼는 것"느낌. FROM 서브쿼리랑 동작 완전히 동일, 가독성 차이만 있음.
같은 서브쿼리를 여러 번 써야 할 때 쓰면 좋음. 파이썬에서 자주 쓰이는 코드 함수로 따로 빼서 재사용 하는 것처럼
WITH 이름 AS (
    SELECT ...   -- 여기서 먼저 계산
)
SELECT *
FROM 이름        -- 테이블처럼 재사용
WHERE ...

-- 서브쿼리 방식
SELECT * FROM (SELECT ...) AS A WHERE ...
-- CTE 방식 — 위에서 아래로 읽힘
WITH A AS (SELECT ...)
SELECT * FROM A WHERE ...

==============================================================================
------------------------------- SQL 실행 순서 , 집계함수 실행 위치 ---------------------------------

작성 순서          실제 실행 순서
SELECT     →    1. FROM    (테이블 불러오기) → 테이블 메모리에 올림
FROM       →    2. WHERE   (행 필터링)      → 행을 '한 줄씩' 보면서 조건 판단  ← 아직 행 다 훑기 전 (= 테이블 전체 스캔 X)이므로 집계함수 불가
WHERE      →    3. GROUP BY(그룹 묶기)      → 'WHERE 통과한 행'들(= 줄어든 행들) 그룹으로 묶음 → 집계함수 실행 시 테이블 전체 스캔
GROUP BY   →    4. HAVING  (그룹 필터링)
HAVING     →    5. SELECT  (컬럼 선택)      → 최종 출력할 컬럼 선택. 윈도우 함수 있을 경우 반드시 SELECT에서 계산됨
ORDER BY   →    6. ORDER BY(정렬)

★ WHERE 절에 집계함수 사용 불가. HAVING 절은 집계함수 가능 ★ -- 일반 컬럼 조건은 둘 다 가능
Q. 왜 굳이 WHERE를 쓰나? -> 실행 순서 때문에 성능 차이 발생
-- WHERE 단계  → 행 필터 → 줄어든 행으로 GROUP BY
-- HAVING 단계 → GROUP BY 다 하고 나서 필터
예시: 100만 행짜리 테이블에서 category = '전자' 조회
WHERE 사용: (WHERE category = '전자')
100만 행 → WHERE → 1000행 → GROUP BY → 집계
                   ^^^^^^ 일찍 걸러냄 ✅
HAVING 사용: (GROUP BY category HAVING category = '전자')
100만 행 → GROUP BY → 집계 → HAVING → 1000행
           ^^^^^^^^^^^^^^^^ 전부 처리하고 나서 버림 ❌

-- WHERE PRICE = MAX(PRICE) -- ❌ 이게 왜 안되냐면
1. FROM FOOD_PRODUCT  → 테이블 전체 행 불러옴
2. WHERE PRICE = MAX(PRICE)  → 아직 모든 행들을 다 훑기 전임. 집계함수값 구하려면 테이블 전체 다 스캔해야 하는데,
WHERE는 지금 이 행이 조건에 맞는지 위에서부터 한 줄씩 판단하는 단계.
| FOOD_ID | PRICE |
|---------|-------|
| F001    | 3000  |  ← WHERE가 이 행 봄 → "MAX가 얼만데?" → 모름 ❌
| F002    | 9000  |  ← 아직 여기 안 옴
| F003    | 5000  |  ← 아직 여기 안 옴
-- WHERE PRICE = (SELECT MAX(PRICE) FROM FOOD_PRODUCT) -- 해결책 : 서브쿼리
1. 서브쿼리 먼저 실행  → MAX(PRICE) = 9000 확정
2. FROM 테이블 불러옴
3. WHERE PRICE = 9000  → 이제 비교 가능 ✅
-- MAX()같은 집계함수가 테이블의 모든 행 다 훑는 시기는 언제인가?
-- -> GROUP BY / SELECT 단계 — WHERE를 통과한 행이 전부 확정된 이후
WHERE 통과한 행 전부 확정 -- 행 하나하나 판단하므로 단일값, 목록(IN)만 허용. 윈도우함수X. 테이블 전체 스캔X
         ↓
GROUP BY → 묶음
         ↓
집계함수 실행 (MAX, SUM, COUNT...) ← 여기서 전체 스캔
         ↓
HAVING → 집계 결과로 필터

==============================================================================
------------------------------- 문제 키워드 → 함수 매핑 ---------------------------------
🔢 COUNT
"몇 명"
"몇 개"
"건수"
"횟수"
"~한 경우의 수"

➕ SUM
"총 ~"
"합계"
"전체 ~"
"누적 ~"

📅 날짜 함수
"~년도별"         → YEAR()
"~월별"           → MONTH()
"오늘 기준"       → NOW(), CURDATE()
"N일 이내"        → DATE_SUB()
"기간 차이"       → DATEDIFF()
"날짜 형식 변환"  → DATE_FORMAT()

🏷️ GROUP BY 트리거 -- "~별"이 보이면 GROUP BY 반사적으로 떠올릴 것
"~별로"   ← 이게 핵심
"~마다"

🔍 HAVING vs WHERE 구분
"그 중에서 ~개 이상인 것"  → HAVING COUNT() >= N
"평균이 ~이상인 그룹"      → HAVING AVG() >= N
(집계 결과에 조건 걸 때)

"가격이 ~이상인 것"        → WHERE PRICE >= N
(집계 전 일반 조건)

🪟 서브쿼리 트리거 -- 집계값(MAX 등)을 구한 뒤 → 그 행의 다른 컬럼도 필요하면 서브쿼리
"가장 ~한 것의 [다른 정보]"  ← 오늘 문제 패턴
"~중에서 최고/최저"
"~와 같은 [다른 컬럼]"
-- 문제 요구조건 : 가격이 제일 비싼 식품의 식품 ID, 식품 이름, 식품 코드, 식품분류, 식품 가격을 조회
-- '가장 비싼 식품'의 = 집계값(MAX)구한 뒤 -> 식품ID, 이름, 코드, 분류, 가격 조회 = 그 행의 다른 컬럼도 필요
서브쿼리 위치별 트리거
위치         트리거                                     키워드예시
SELECT   "각 행마다 ~값 함께 출력"                       각 상품 가격과 전체 평균 같이 보기, 각 직원의 급여와 부서 평균 급여를 같이
FROM     "윈도우 함수" "중간 결과를 테이블 -> 다시 조건"   순위 매긴 후 N등만 뽑기, 카테고리별 평균 구하고 → 그 중 평균 5000 이상만, 월별 매출 구하고 → 상위 3개월만
WHERE    "가장 ~한 것" "~와 같은" "~목록에 속하는"        최고가 상품, 주문된 적 있는 상품만, 전체 평균보다 비싼 상품, 주문 테이블에 존재하는 고객만
HAVING   "그룹 집계값이 전체 평균보다 ~"                  평균 이상인 그룹만, 카테고리 평균가격이 전체 평균보다 높은 카테고리만, 주문 건수가 평균 주문 건수보다 많은 고객
① SELECT절 — "각 행마다 비교값 함께 보고 싶을 때"
② FROM절 — "중간 가공이 필요할 때"
③ WHERE절 — "조건의 기준값이 고정이 아닐 때"
④ HAVING절 — "그룹 집계값을 전체 집계값과 비교할 때"

1. 윈도우 함수 트리거
"~별 순위"
"~순으로 N번째"
"전체 대비 각 행의 ~"
"누적 합계"
"이전/다음 행 값"
"그룹 내 순위"

순위, N번째 -> RANK(), DENSE_RANK(), ROW_NUMBER()
누적 합계   -> SUM() OVER()
이전 행 값  -> LAG()
다음 행 값  -> LEAD()