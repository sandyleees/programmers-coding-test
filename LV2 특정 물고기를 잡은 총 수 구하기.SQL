-- 테이블 구조 : 
-- FISH_INFO -- 잡은 물고기들의 정보
-- ID        INTEGER  NOT NULL
-- FISH_TYPE INTEGER  NOT NULL
-- LENGTH    FLOAT    NULL      -- 10cm 이하는 NULL
-- TIME      DATE     NOT NULL

-- FISH_NAME_INFO
-- FISH_TYPE INTEGER  NOT NULL
-- FISH_NAME VARCHAR  NOT NULL

-- Q. FISH_INFO 테이블에서 잡은 BASS와 SNAPPER의 수를 출력하는 SQL 문을 작성해주세요.
-- 컬럼명은 'FISH_COUNT`로 해주세요.
====================================================================================

-- 1. 조인
SELECT COUNT(*) AS FISH_COUNT
FROM FISH_INFO F INNER JOIN FISH_NAME_INFO N ON F.FISH_TYPE = N.FISH_TYPE
WHERE FISH_NAME IN ('BASS','SNAPPER')

-- # 물고기 타입으로 엮여있는 테이블 --- 이름은 다른 테이블에 있음
-- # 이름이 BASS, SNAPPER인 물고기 잡힌 수 (조인) ID COUNT하면될듯
-- # 조인하고 타입별 그룹 짓고 아이디 카운트
-- # -> 아니지 조인한 테이블 전체 상태 보니까 여기서 굳이 BASS, SNAPPER 그룹 분리할 필요없이 
-- 둘 다 낚은 만큼 카운트하면 되는거잖아. 이러면 WHERE로 해당 물고기 아닌 행 다 날리고 전부 카운트하면 되잖아

-- 2. 서브쿼리
SELECT COUNT(*) AS FISH_COUNT
FROM FISH_INFO
WHERE FISH_TYPE IN (SELECT FISH_TYPE
                   FROM FISH_NAME_INFO
                   WHERE FISH_NAME IN ('BASS','SNAPPER'))

===========================================================================================
----------------------------------- SQL JOIN 종류 ---------------------------------------

[A 테이블]          [B 테이블]
id | name           id | score
1  | Alice          1  | 90
2  | Bob            3  | 85
3  | Carol

-- (INNER) JOIN -- 양쪽 모두 일치하는 행만 (교집합) → 서브쿼리로 대체 가능 
--  → 양쪽 모두 일치하는 것만 필요할 때 사용
SELECT * FROM A INNER JOIN B ON A.id = B.id;
결과:
id | name  | score
1  | Alice | 90
3  | Carol | 85

참고> → id가 1개만 나온 것처럼 보여줬는데 실제로는: id 컬럼이 2개 나오는 게 맞음. 
JOIN은 두 테이블을 옆에 붙이는 것이기 때문. 설명 편의상 하나로 합쳐서 보여준 것 (아래 설명하는 모든 JOIN도 마찬가지임)
→ ON 조건으로 같은 값임을 보장했을 뿐 두 테이블의 컬럼을 물리적으로 합쳤기 때문에 id 컬럼 중복돼서 나옴
A.id | name  | B.id | score
1    | Alice | 1    | 90
3    | Carol | 3    | 85
-- 해결법:  JOIN 후 SELECT * 는 지양하고 필요한 컬럼만 명시하는 것이 권장됨
SELECT * 대신 필요한 컬럼만 명시
SELECT F.ID, F.FISH_TYPE, N.FISH_NAME ...
→ 어느 테이블의 FISH_TYPE인지 명시해서 1개만 선택


-- LEFT JOIN -- A 전체 + B에서 일치하는 행 (없으면 NULL) → 서브쿼리 대체 불가 (서브쿼리는 NULL 행을 만들어내지 못함 - 불일치 시 행 자체가 제외됨)
-- → 기준 테이블(왼쪽) 전체를 보존해야 할 때 사용 
SELECT * FROM A LEFT JOIN B ON A.id = B.id;
결과:
id | name  | score
1  | Alice | 90
2  | Bob   | NULL
3  | Carol | 85
-- 얘네도 실제로는 id 컬럼 2개 보이는데 설명 편의상 하나로 합쳐서 보여준 것

-- RIGHT JOIN -- B 전체 + A에서 일치하는 행 (없으면 NULL) → 서브쿼리 대체 불가 (서브쿼리는 NULL 행을 만들어내지 못함 - 불일치 시 행 자체가 제외됨)
SELECT * FROM A RIGHT JOIN B ON A.id = B.id;
결과:
id | name  | score
1  | Alice | 90
3  | Carol | 85

-- FULL OUTER JOIN -- 양쪽 모두 포함, 없는 쪽은 NULL (합집합) → 서브쿼리 대체 불가 (서브쿼리는 NULL 행을 만들어내지 못함 - 불일치 시 행 자체가 제외됨)
-- → 양쪽 모두 빠짐없이 출력해야 할 때
SELECT * FROM A FULL OUTER JOIN B ON A.id = B.id;
결과:
id | name  | score
1  | Alice | 90
2  | Bob   | NULL
3  | Carol | 85

-- CROSS JOIN -- 모든 행의 조합 (3 x 2 = 6행) (곱집합)
-- → 모든 조합이 필요할 때. 실무에서 거의 안 씀
SELECT * FROM A CROSS JOIN B;
결과:
Alice/90, Alice/85, Bob/90, Bob/85, Carol/90, Carol/85

===========================================================================================
----------------------------INNER JOIN VS 서브쿼리 + DB 옵티마이저 ---------------------------------------

-- 이 문제에서 INNER JOIN을 쓴 이유:
BASS, SNAPPER만 카운트 → 이름이 없는 물고기는 필요 없음
→ 양쪽 테이블에 모두 존재하는 행만 필요
→ INNER JOIN

LEFT JOIN   → 예) 물고기 전체 목록에 이름 붙이기
                  (이름 없는 물고기도 출력해야 할 때)


-- Q. 서브쿼리 VS INNER JOIN 시 어떤게 더 권장되는가?
결론부터: 대부분 JOIN이 권장됨
서브쿼리  → 메인쿼리 행마다 서브쿼리를 반복 실행할 수 있음
            (DB 옵티마이저에 따라 다르지만 비효율 가능성)
JOIN      → 옵티마이저가 최적화하기 용이
            인덱스 활용이 더 잘 됨
            대용량 데이터에서 성능 차이 발생

참고> DB 옵티마이저 (Query Optimizer)
SQL은 "무엇을 가져와라"만 명시하고 "어떻게 가져올지"는 명시하지 않음
옵티마이저는 DB 내부에서 자동으로 "어떻게 가져올지" 최적 실행 계획을 결정하는 엔진 (지가 알아서)
예시:
SELECT * FROM A JOIN B ON A.id = B.id
WHERE A.name = 'Alice'
사람이 쓴 쿼리 순서  → JOIN 먼저, WHERE 나중
옵티마이저 실제 실행 → WHERE로 A 먼저 줄이고, 그 다음 JOIN
                       (더 빠르니까 순서 바꿔서 실행)
즉: SQL 작성 순서  ≠  실제 실행 순서
옵티마이저가 중간에서 알아서 최적화해줌
그래서 아까 말한 내용과 연결하면: 서브쿼리도 옵티마이저가 JOIN으로 변환해서 실행하는 경우 있음
→ 그래서 "대부분 성능 차이 없다"는 말이 나오는 것
단, 옵티마이저가 항상 완벽하진 않아서 JOIN 명시가 더 안전
---

대부분 JOIN이 권장되나, 예외 있음:

IN (서브쿼리)         → 서브쿼리 결과가 작으면 성능 차이 거의 없음
EXISTS (서브쿼리)     → 조건 만족하는 행 하나만 찾으면 멈춤
                        대용량에서 JOIN보다 빠른 경우 있음

---

정리:

단순 필터링 (이번 문제처럼)  → JOIN, 서브쿼리 큰 차이 없음
대용량 / 복잡한 쿼리         → JOIN 권장
"존재 여부"만 확인할 때      → EXISTS 서브쿼리가 유리할 수도 있음

코딩테스트 수준에서는 성능보다
가독성 좋고 익숙한 방식으로 작성하면 됨


