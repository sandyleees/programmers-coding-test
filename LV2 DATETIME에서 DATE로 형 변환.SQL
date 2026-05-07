-- ANIMAL_INS 테이블에 등록된 모든 레코드에 대해, 각 동물의 아이디와 이름, 
-- 들어온 날짜1를 조회하는 SQL문을 작성해주세요. 
-- 이때 결과는 아이디 순으로 조회해야 합니다.

SELECT ANIMAL_ID, NAME, DATE_FORMAT(DATETIME,'%Y-%m-%d') AS 날짜
FROM ANIMAL_INS
ORDER BY ANIMAL_ID

-- 날짜형 함수 관련해서 싹 정리할 필요 있겠음. 이는 문자열 함수도 마찬가지임 -------------------

-- DATETIME형 2017-04-13 16:29:00 이렇게 생겼음.
-- DATE_FORMAT()함수 써서 시,분,초 제거하고  2017-04-13 이런 식으로 출력되게함


-- ① 현재 시각 가져오기
-- sqlSELECT NOW();              -- 2026-05-07 14:30:00
-- SELECT CURRENT_TIMESTAMP;  -- 동일
-- SELECT CURDATE();          -- 2026-05-07 (날짜만)
-- SELECT CURTIME();          -- 14:30:00 (시간만)

-- ② 형식 변환 — DATE_FORMAT() -- 원하는 형태로 출력 변환
-- SELECT DATE_FORMAT(created_at, '%Y년 %m월 %d일') FROM orders;
-- -- 결과: 2026년 05월 07일
-- SELECT DATE_FORMAT(created_at, '%Y-%m-%d %H:%i') FROM orders;
-- -- 결과: 2026-05-07 14:30

-- 주요 포멧 기호 : 
-- %Y  4자리 연도 2026
-- %m  2자리 월   05
-- %d  2자리 일   07
-- %H  24시간    14
-- %i    분      30
-- %s    초      00

-- ③ 문자열 → DATETIME 변환 — STR_TO_DATE() -- 문자열을 DATETIME으로 파싱
-- SELECT STR_TO_DATE('2026-05-07 14:30:00', '%Y-%m-%d %H:%i:%s');