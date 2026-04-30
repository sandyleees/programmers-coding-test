-- PRODUCT 테이블에서 상품 카테고리 코드(PRODUCT_CODE 앞 2자리) 별 상품 개수를 
-- 출력하는 SQL문을 작성해주세요. 결과는 상품 카테고리 코드를 기준으로 
-- 오름차순 정렬해주세요.

SELECT SUBSTRING(PRODUCT_CODE,1,2) AS CATEGORY, COUNT(*) AS PRODUCTS
FROM PRODUCT
GROUP BY CATEGORY
ORDER BY CATEGORY 

-- 다른 방법 : LEFT(컬럼명, 자를 개수) 사용
-- SELECT LEFT(PRODUCT_CODE, 2) AS CATEGORY, COUNT(*) AS PRODUCTS

-- 다른 방법 : SUBSTRING = SUBSTR 동일, DISTINCT 활용 
-- (이 경우 PRODUCT_ID는 보통 PK로 쓰이니까 무조건 중복값 없을거기 때문에 무의미하긴할듯)
-- SELECT SUBSTR(PRODUCT_CODE,1,2)AS CATEGORY, COUNT(DISTINCT PRODUCT_ID) AS PRODUCTS

-- 참고사항 : GROUP BY, ORDER BY는 SELECT에 쓰인 컬럼 순번을 지정해서 가능
-- GROUP BY 1 = GROUP BY CATEGORY = GROUP BY SUBSTRING(PRODUCT_CODE,1,2)

-- 자주 쓰는 문자열 함수
-- LENGTH(str)               문자열 길이      LENGTH('hello') → 5
-- UPPER(str)                 대문자 변환     UPPER('hello') → HELLO
-- LOWER(str)                 소문자 변환     LOWER('HELLO') → hello
-- TRIM(str)                  양쪽 공백 제거  TRIM(' hi ') → hi
-- SUBSTRING(str, start, len) 문자열 자르기   SUBSTRING('hello', 2, 3) → ell
-- CONCAT(a, b)              문자열 합치기    CONCAT('a', 'b') → ab
-- REPLACE(str, from, to)    문자 교체        REPLACE('a-b', '-', '') → ab
-- LIKE                       패턴 매칭       WHERE name LIKE 'A%'
-- INSTR(str, target)        위치 찾기       INSTR('hello', 'l') → 3
-- LPAD(str, len, pad)       왼쪽 채우기      LPAD('7', 3, '0') → 007
-- RPAD(str, len, pad)       오른쪽 채우기     RPAD('7', 3, '0') → 700