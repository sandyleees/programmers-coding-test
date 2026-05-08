-- 테이블 구조 : 
-- FISH_INFO -- 잡은 물고기들의 정보
-- ID        INTEGER  NOT NULL 
-- FISH_TYPE INTEGER  NOT NULL
-- LENGTH    FLOAT    NULL      -- 10cm 이하는 NULL
-- TIME      DATE     NOT NULL

-- FISH_NAME_INFO
-- FISH_TYPE INTEGER  NOT NULL
-- FISH_NAME VARCHAR  NOT NULL

-- FISH_NAME_INFO에서 물고기의 종류 별 물고기의 이름과 잡은 수를 출력하는 SQL문을 작성해주세요.
-- 물고기의 이름 컬럼명은 FISH_NAME, 잡은 수 컬럼명은 FISH_COUNT로 해주세요.
-- 결과는 잡은 수 기준으로 내림차순 정렬해주세요.
========================================================================================================

SELECT B.FISH_COUNT,A.FISH_NAME
FROM FISH_NAME_INFO A 
RIGHT JOIN -- 이거 왜 LEFT나 INNER JOIN하면 문제 실패 뜰까? 
(SELECT FISH_TYPE, COUNT(*) AS FISH_COUNT
  FROM FISH_INFO
  GROUP BY FISH_TYPE) B ON A.FISH_TYPE = B.FISH_TYPE
ORDER BY B.FISH_COUNT DESC

# 물고기 종류 '별' - GROUP BY -> 이름, 잡은 수 COUNT
# 잡은 수 기준 내림차순

# 이름 기준 그룹핑하면 SELECT에 이름, 잡은수 모두 작성 가능한데 문제 요구사항에 엄밀히 맞지않고 (종류 별이라고 했으니)
# 타입 기준 그룹핑하면 SELECT에 이름 넣으려면 서브쿼리 써야하나? 이름도 집계함수로 묶을수는 없잖아
# 조인을 해볼까 일단? 근데 이너조인은 또 서브쿼리로 가능하다고했는데. 

# 이름테이블 레프트조인은? (이너 조인도 됨)
# 타입 | 이름 | 타입 | 잡은수 -> 테이블 이렇게 나오더라. 조인은 테이블 물리적으로 붙이는거라 
# SELECT * 하면 조인하는 두 테이블의 타입이 모두 포함된 테이블 출력

# 이렇게 작성해도 돌아감 
-- SELECT절에 FISH_NAME까지 적기 위해 그룹핑에 문제가 요구하지 않은 FISH_NAME까지 작성해야하는 문제 있음
-- 엄밀히 말하면 서브쿼리까지 해서 JOIN하는게 요구사항에 더 충실함
SELECT COUNT(A.ID) AS FISH_COUNT, B.FISH_NAME
FROM FISH_INFO A INNER JOIN FISH_NAME_INFO B ON A.FISH_TYPE = B.FISH_TYPE
GROUP BY B.FISH_TYPE, B.FISH_NAME
ORDER BY 1 DESC
-- 그렇다고 GROUP BY B.FISH_TYPE 하고나서 SELECT 절에 MIN(FISH_NAME) 이런식으로 집계함수 쓰는 것 역시
-- 동작은 하겠으나 잘못된 방식 (채점은 통과하더라도 실무에서는 잘못된 쿼리)

-- FISH_NAME으로 GROUP BY 해도 되는거 아는데 이 테이블의 경우 TYPE과 NAME이 1대1 매핑이라 결과는 나오겠지만
-- 엄밀히 요구하는 문제 요구사항에 충실하지 못해서 하지 않을 것

===================================================================================
------ 서브쿼리까지 걸어서 JOIN 한 쿼리문에서 INNER JOIN이나 LEFT JOIN은 채점하면 실패되는데 RIGHT는 되는 이유가 뭘까?----
기준 테이블이 어디냐의 차이

FROM 순서:
FROM FISH_NAME_INFO A       ← 왼쪽
JOIN (서브쿼리) B            ← 오른쪽

샘플 데이터:
FISH_INFO                    FISH_NAME_INFO
FISH_TYPE | COUNT            FISH_TYPE | FISH_NAME
1         | 3               1         | BASS
2         | 2               2         | SNAPPER
                            3         | BLUEGILL  ← FISH_INFO에 없음

---

LEFT JOIN:
A(FISH_NAME_INFO) 기준 전체 보존
→ FISH_INFO에 잡힌 적 없는 물고기도 출력
→ FISH_COUNT가 NULL인 행 포함
→ 채점 실패
-- 기준 = FISH_NAME_INFO (왼쪽)
FISH_TYPE | FISH_COUNT | FISH_NAME
1         | 3          | BASS
2         | 2          | SNAPPER
3         | NULL       | BLUEGILL  ← NULL 행 포함
← NULL 행이 결과에 포함되어 채점 실패

INNER JOIN:
양쪽 모두 일치하는 것만
→ 이론상 맞아야 하는데 실패했다면
→ 아마 채점 데이터에 FISH_NAME_INFO에는 있지만
   FISH_INFO에는 없는 물고기 종류 존재
→ 그 행이 INNER JOIN에서 제외되어 누락
FISH_TYPE | FISH_COUNT | FISH_NAME
1         | 3          | BASS
2         | 2          | SNAPPER
← BLUEGILL 누락 (양쪽 모두 있어야 출력) ← 채점 데이터에 이런 케이스 있으면 실패
-- Q. FISH_NAME_INFO에는 있지만 FISH_INFO에는 없는 물고기 종류 제외되어도 문제가 원하던 바 아닌가?
-- A. 맞는 말. 문제 요구사항: "잡은 물고기의 종류별 이름과 잡은 수" → 잡힌 적 없는 물고기(BLUEGILL)는 출력 불필요
-- 그럼 왜 실패처리하는가? -> 채점 데이터를 직접 볼 수 없어서 확실하지 않음 (채점 문제인것같음...)


RIGHT JOIN: -- 이게 INNER JOIN보다 엄밀하게 생각하면 맞아서 통과시켜준건가
B(서브쿼리) 기준 전체 보존
→ 서브쿼리는 이미 FISH_INFO에서 잡힌 것만 COUNT한 결과
→ 잡힌 물고기 종류가 모두 출력됨
→ 채점 통과
-- 기준 = 서브쿼리 (오른쪽)
서브쿼리는 FISH_INFO에서 잡힌 것만 이미 필터링된 상태
FISH_TYPE | FISH_COUNT | FISH_NAME
1         | 3          | BASS
2         | 2          | SNAPPER
← BLUEGILL 없음 (서브쿼리에 없으니까)
← NULL 행 없음
← 채점 통과


참고> JOIN 관련 샘플 테이블도 다 FISH_TYPE 2번씩 출력되는데 생략한 것
실제 JOIN 결과:
A.FISH_TYPE | FISH_NAME | B.FISH_TYPE | FISH_COUNT
1           | BASS      | 1           | 3
2           | SNAPPER   | 2           | 2
설명 편의상 FISH_TYPE 하나로 합쳐서 보여준 것
SELECT절에서 어느 쪽 FISH_TYPE을 선택할지 명시하지 않으면 실제로는 2개 컬럼이 출력됨
---

결론:
기준을 어느 테이블로 잡느냐가 핵심
이 쿼리 구조에서는 서브쿼리(B)가 기준이 되어야 하므로
RIGHT JOIN이 맞음

단, 테이블 순서를 바꾸면 LEFT JOIN으로도 동일하게 작성 가능: