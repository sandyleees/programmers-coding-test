--  동물 보호소에 들어온 동물 이름 중, 이름에 "EL"이 들어가는 개의 아이디와 이름을 조회하는 SQL문을 작성해주세요. 
--  이때 결과는 이름 순으로 조회해주세요. 단, 이름의 대소문자는 구분하지 않습니다.

SELECT ANIMAL_ID, NAME
FROM ANIMAL_INS
WHERE ( NAME LIKE "%El%" 
    OR NAME LIKE "%el%"
    OR NAME LIKE "%EL%"
    OR NAME LIKE "%eL%" )
    AND ANIMAL_TYPE = "Dog"
ORDER BY NAME

-- 조건 : '개' 이름 el 포함 --- 전체 테이블에서 조건 체크하면 되니까 WHERE에 작성
-- 아이디, 이름 조회 이름 순으로 대소문자구분X --- 이거 대소문자 관련 문자열 함수 써야하는가? -> 쓰는게 권장됨

SELECT ANIMAL_ID, NAME
FROM ANIMAL_INS
WHERE UPPER(NAME) LIKE "%EL%"
    AND ANIMAL_TYPE = "Dog"
ORDER BY NAME

==================================================================================

문제 풀이 TIP : 대소문자 구분 필요없는 경우 UPPER()나 LOWER()함수 써서 대문자or소문자 통일 후 조건 거는 걸 권장함
훨씬 코드 길이 단축되고 가독성 높아짐

 NAME LIKE "%El%" 
    OR NAME LIKE "%el%"
    OR NAME LIKE "%EL%"
    OR NAME LIKE "%eL%" 이 4줄을

 WHERE UPPER(NAME) LIKE "%EL%" 이렇게 1줄로 축소 가능함

----------------------------------- AND, OR 연산자 우선순위 ---------------------------------------

-- Q. 왜 이런 식으로 괄호 안 묶고 작성하면 오답처리되는가?
SELECT ANIMAL_ID, NAME
FROM ANIMAL_INS
WHERE NAME LIKE "%El%" 
    OR NAME LIKE "%el%"
    OR NAME LIKE "%EL%"
    OR NAME LIKE "%eL%"
    AND ANIMAL_TYPE = "Dog"
ORDER BY NAME

★ SQL에서 AND는 OR보다 우선순위가 높습니다. ★

그래서 지금 쿼리는 이렇게 해석됩니다:
WHERE NAME LIKE "%El%"
   OR NAME LIKE "%el%"
   OR NAME LIKE "%EL%"
   OR (NAME LIKE "%eL%" AND ANIMAL_TYPE = "Dog")  -- ← AND가 먼저 묶임!
즉, %eL% 조건만 Dog 필터가 걸리고, 나머지는 모든 동물이 포함되는 버그 발생.