-- '통풍시트', '열선시트', '가죽시트' 중 하나 이상의 옵션이 포함된 자동차가 
-- 자동차 종류 별로 몇 대인지 출력하는 SQL문을 작성해주세요. 
-- 이때 자동차 수에 대한 컬럼명은 CARS로 지정하고, 
-- 결과는 자동차 종류를 기준으로 오름차순 정렬해주세요.
-- 주의 : OPTION이 '가죽시트,열선시트,후방카메라' 이런 식으로 통문자열로 저장되어있음

-- 1. 통문자열 필터링 LIKE 사용 ---- 단순/직관적이지만 조건이 많아지면 코드가 길어짐
SELECT CAR_TYPE, COUNT(*) AS CARS
FROM CAR_RENTAL_COMPANY_CAR
WHERE OPTIONS LIKE "%통풍시트%"
    OR OPTIONS LIKE "%열선시트%" 
    OR OPTIONS LIKE "%가죽시트%"
GROUP BY CAR_TYPE
ORDER BY 1

-- 2. 콤마 구분 문자열 전용 함수 FIND_IN_SET --- 콤마 구분 정확하지만 조건 많아지면 코드 길어짐
SELECT CAR_TYPE, COUNT(*) AS CARS
FROM CAR_RENTAL_COMPANY_CAR
-- '가죽시트'가 포함되어 있으면 1 이상 반환, 없으면 0
WHERE FIND_IN_SET('가죽시트', OPTIONS) > 0
   OR FIND_IN_SET('열선시트', OPTIONS) > 0
   OR FIND_IN_SET('통풍시트', OPTIONS) > 0
GROUP BY CAR_TYPE
ORDER BY 1

3. 정규표현식(Regular Expression) — 문자열 패턴 매칭 함수 사용 ----- 조건이 많을수록 REGEXP가 가장 짧아짐
SELECT CAR_TYPE, COUNT(*) AS CARS
FROM CAR_RENTAL_COMPANY_CAR
WHERE OPTIONS REGEXP '통풍시트|가죽시트|열선시트' -- | = OR 의미 (정규표현식에서)
GROUP BY CAR_TYPE
ORDER BY 1


===================================================================================

★ WHERE 에서 조건 걸 목록이 테이블 형태(여러행 + 1열) = 개별 문자열('A','B','C') 구성이 아니라 통문자열 구성('A,B,C')이면
IN, EXISTS 쓰는게 아니라 LIKE, FIND_IN_SET 써야됨. 통문자열 굳이 'A','B','C'처럼 문자열 쪼개서 IN 가능하지만 비추 ★
IN, EXISTS   → 행으로 나눠진 목록에 사용 ✅ 정확한 이해
LIKE         → 통문자열 포함 여부 검색   ✅ 정확한 이해
-- 처음에 이 문제 풀려고 설계할 때 EXISTS 쓰면 되지 않나 싶었는데 통문자열이라 목록 검색 EXISTS로 불가한 구조임

=====================================================================================
------------- REGEXP(Regular Expression) 정규표현식 문자열 패턴 매칭 함수 VS LIKE 함수 -------------------

-- LIKE vs REGEXP 차이 : 문자열 내부 값 조건걸어서 검색해야되는데 조건 많고 복잡할수록 REGEXP 사용하면 됨
LIKE    → 와일드카드 (단순 패턴) - 2개 존재 (% : 아무 문자 0개 이상, _ : 아무 문자 정확히 1개)
REGEXP  → 정규표현식 (복잡한 패턴) - LIKE로 못하는 복잡한 패턴 처리 가능, 조건 많을수록 유리

REGEXP 메타문자
|  (파이프)   → OR            예) 가죽시트|열선시트
.  (점)       → 아무문자 1개   예) A.C = ABC, A1C
*  (별)       → 앞문자 0개이상 예) AB* = A, AB, ABB
+  (플러스)   → 앞문자 1개이상 예) AB+ = AB, ABB
?  (물음표)   → 앞문자 0또는1  예) AB? = A, AB
^  (캐럿)     → 문자열 시작   예) ^김 = 김으로 시작
$  (달러)     → 문자열 끝     예) 찌개$ = 찌개로 끝
[] (대괄호)   → 문자집합 1개  예) [ABC] = A or B or C
[^](대괄호^)  → 집합 제외     예) [^ABC] = A,B,C 아닌것

-- 기본 OR 검색
WHERE OPTIONS REGEXP '가죽시트|열선시트|통풍시트'
-- '가죽시트,열선시트,후방카메라' → 매칭 ✅

-- 특정 문자로 시작
WHERE FOOD_NAME REGEXP '^김'
-- '김치', '김밥' → ✅ / '볶음김치' → ❌

-- 특정 문자로 끝
WHERE FOOD_NAME REGEXP '찌개$'
-- '김치찌개', '된장찌개' → ✅

-- 숫자 포함 여부
WHERE PRODUCT_CODE REGEXP '[0-9]'
-- 'A1B2' → ✅ / 'ABC' → ❌

-- 정확한 콤마 구분 매칭
WHERE OPTIONS REGEXP '(^|,)가죽시트(,|$)'
-- '가죽시트,열선시트' → ✅
-- '고급가죽시트,열선시트' → ❌ (앞에 다른 문자 있으면 제외)

