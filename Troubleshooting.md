# 🧩 Troubleshooting

## 음식점-재료 매핑을 프론트에서 관리하여 사용자마다 다른 상태가 노출되는 문제

### 🧱 문제 상황

- 지도 화면에서 음식점 위치를 표시할 때, 각 음식점을 **재료 이미지 기반 마커**로 표현하는 기능을 구현했다.
- 초기 설계:
  - 음식점에 대한 재료를 **프론트엔드에서 하루 1회 랜덤으로 지정**하는 방식을 고려했다.<br>
    but) **사용자마다 같은 음식점에서 다른 재료 마커가 표시되는 문제**가 발생할 수 있었다.
- 그 결과:
  - 모든 사용자에게 동일해야 하는 음식점-재료 조합이 보장되지 않았고 서비스 전반의 정합성과 일관성이 깨질 가능성이 있었다.

### 🔍 원인 분석

- 음식점-재료 매핑은 개인의 상태가 아닌 **모든 사용자에게 동일하게 적용되어야 하는 전역 상태**였다.
- 프론트엔드에서 관리하려다 보니 접속 시점과 앱 재실행 여부 등에 따라 사용자별로 서로 다른 결과가 만들어질 수밖에 없는 구조였다.
- 또한, "하루 1회 변경"이라는 규칙을 프론트엔드 단에서 정확하게 보장하기도 어려웠다.

### 🎯 해결 전략

1. **상태 소유권을 백엔드로 이동**
    - 음식점-재료 매핑을 프론트엔드가 아닌 **백엔드에서 관리**하도록 구조를 변경했다.
    - 이를 통해 모든 사용자에게 동일한 상태를 제공하도록 했다.

2. **서버 라이프사이클을 활용한 자동 갱신**
    - `@PostConstruct`를 사용해 **서버 시작 시 한 번** 재료를 초기화
    - `@Scheduled(cron = "0 0 0 * * *")`를 사용해 **매일 자정에 재료를 재지정**
    - "하루 1회 변경" 규칙을 시스템 레벨에서 보장했다.

3. **멀티스레드 기반 병렬 처리**
    - 음식점 수가 많아질 것을 고려해 음식점별 재료 지정 작업을 **멀티스레드로 병렬 처리**하도록 구현했다.
    - 이를 통해 초기화 및 갱신 작업의 처리 시간을 줄였다.

### 🧩 구현 요약
- 음식점-재료 매핑을 백엔드 책임으로 이동
- 서버 시작 시(`@PostConstruct`) 전체 음식점 재료 초기화
- 매일 자정(`@Scheduled`) 재료 랜덤 재지정
- 음식점 단위 작업을 멀티스레드로 병렬 처리
- 프론트엔드는 지도 경계를 기준으로 음식점 정보를 조회하고 **백엔드에서 결정된 재료 정보를 그대로 렌더링**

### 🎉 개선 효과

- 모든 사용자에게 **동일한 음식점-재료 조합**을 제공할 수 있게 되었다.
- 사용자 접속과 무관하게 서비스 상태의 **정합성과 일관성**이 유지되었다.
- "하루 1회 변경" 규칙이 서버에서 보장되어 예측 가능한 동작을 확보했다.
- 음식점 수가 증가하더라도 병렬 처리 구조로 안정적인 확장이 가능해졌다.
<br><br>

### 📋 핵심 코드
<details>
<summary>코드 보기</summary>
<div markdown="1">

#### 📌 1. 서버 시작 시 음식점 재료 초기화 (@PostConstruct)
```java
@PostConstruct
public void initializeIngredients() {
  assignRandomIngredients();
}
```
#### 📌 2. 매일 자정에 음식점 재료 재지정 (@Scheduled)
```java
@Scheduled(cron = "0 0 0 * * *")
public void assignRandomIngredients() {
  // 전체 재료 조회
  List<Ingredient> allIngredients = ingredientRepository.findAll();
  if (allIngredients.isEmpty()) { // 재료가 없는 경우 불필요한 처리 방지
    return;
  }

  // 전체 음식점 ID 조회
  List<String> restaurantIds = restaurantRepository.findAll().stream()
          .map(Restaurant::getId)
          .toList();

  // 전체 처리 시간을 줄이기 위해 병렬로 처리
  for (String restaurantId : restaurantIds) {
    executorService.submit(() -> processRestaurantIngredient(restaurantId, allIngredients));
  }
}
```
#### 📌 3. 음식점에 대한 재료 재지정 처리 로직
```java
private void processRestaurantIngredient(String restaurantId, List<Ingredient> allIngredients) {
  // 전체 재료 중 하나를 랜덤으로 선택
  Ingredient newRandomIngredient = allIngredients.get(random.nextInt(allIngredients.size()));

  // 해당 음식점에 이미 재료가 할단되어 있는지 확인
  restaurantIngredientRepository.findByRestaurantId(restaurantId).ifPresentOrElse(
          existingIngredient -> {
            // 기존 재료와 다른 경우에만 변경 -> 불필요한 UPDATE 방지
            if (!existingIngredient.getIngredient().getId().equals(newRandomIngredient.getId())) {
              existingIngredient.setIngredient(newRandomIngredient);
              restaurantIngredientRepository.save(existingIngredient);
            }
          },
          () -> {
            // 기존 매핑이 없는 경우 신규 생성
            RestaurantIngredient newAssignment = new RestaurantIngredient(
                    UUID.randomUUID().toString(),
                    restaurantId,
                    newRandomIngredient
            );
            restaurantIngredientRepository.save(newAssignment);
          }
  );
}
```
#### 📌 4. 비동기 작업을 위한 Executor 설정
```java
@Configuration
@EnableAsync
public class AsyncConfig {
  @Bean(name = "taskExecutor")
  public Executor taskExecutor() {
    ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
    executor.setCorePoolSize(2); // 코어 스레드 수: 상시 유지되는 스레드 수(작없이 없을 때도 유지)
    executor.setMaxPoolSize(5); // 최대 스레드 수: 큐가 가득 차거나 바쁠 때 늘어날 수 있는 상한
    executor.setQueueCapacity(20); // 큐 용량: 코어 스레드가 바쁠 때 대기시킬 작업 수
    executor.setThreadNamePrefix("AsyncExecutor-"); // 스레드 이름 prefix
    executor.initialize();
    return executor;
  }
}
```
</div>
</details>
