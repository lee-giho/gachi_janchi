package com.gachi_janchi.service;

import com.gachi_janchi.dto.*;
import com.gachi_janchi.entity.Title;
import com.gachi_janchi.entity.TitleCondition;
import com.gachi_janchi.entity.User;
import com.gachi_janchi.entity.UserTitle;
import com.gachi_janchi.repository.*;
import com.gachi_janchi.util.JwtProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
public class TitleService {

    private final TitleRepository titleRepository;
    private final UserTitleRepository userTitleRepository;
    private final UserRepository userRepository;
    private final TitleConditionRepository titleConditionRepository;
    private final UserCollectionRepository userCollectionRepository;
    private final UserIngredientRepository userIngredientRepository;
    private final CollectionRepository collectionRepository;
    private final JwtProvider jwtProvider;
    private final IngredientRepository ingredientRepository;

    public List<TitleResponse> getAllTitles() {
        return titleRepository.findAll().stream()
                .map(t -> new TitleResponse(t.getId(), t.getName(),t.getExp()))
                .collect(Collectors.toList());
    }

    public List<UserTitleResponse> getUserTitles(String token) {
        String userId = jwtProvider.getUserId(jwtProvider.getTokenWithoutBearer(token));
        return userTitleRepository.findByUserId(userId).stream()
                .map(ut -> new UserTitleResponse(
                        ut.getUserId(),
                        ut.getTitle().getId(),
                        ut.getTitle().getName(),
                        ut.getAcquiredAt()))
                .collect(Collectors.toList());
    }

    public void changeUserTitle(String token, ChangeUserTitleRequest request) {
        String userId = jwtProvider.getUserId(jwtProvider.getTokenWithoutBearer(token));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("해당 유저가 존재하지 않습니다."));

        if (request.getTitleId() == null) {
            user.setTitle(null);
        } else {
            Title title = titleRepository.findById(request.getTitleId())
                    .orElseThrow(() -> new IllegalArgumentException("해당 칭호가 존재하지 않습니다."));

            boolean hasTitle = userTitleRepository.existsByUserIdAndTitleId(userId, request.getTitleId());
            if (!hasTitle) {
                throw new IllegalArgumentException("해당 칭호를 보유하고 있지 않습니다.");
            }

            user.setTitle(title);
        }

        userRepository.save(user);
    }

    public void claimTitle(String token, ClaimTitleRequest request) {
        String userId = jwtProvider.getUserId(jwtProvider.getTokenWithoutBearer(token));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("유저를 찾을 수 없습니다."));

        Title title = titleRepository.findById(request.getTitleId())
                .orElseThrow(() -> new IllegalArgumentException("칭호가 존재하지 않습니다."));

        boolean alreadyOwned = userTitleRepository.existsByUserIdAndTitleId(userId, title.getId());
        if (alreadyOwned) {
            throw new IllegalStateException("이미 획득한 칭호입니다.");
        }
        user.setExp(user.getExp() + title.getExp());
        userRepository.save(user);

        userTitleRepository.save(new UserTitle(userId, title));
    }

    public void giveTitleToUser(String userId, Title title) {
        boolean alreadyOwned = userTitleRepository.existsByUserIdAndTitleId(userId, title.getId());
        if (!alreadyOwned) {
            userTitleRepository.save(new UserTitle(userId, title));
        }
    }

    public List<TitleConditionResponse> getAllTitleConditions() {
        return titleConditionRepository.findAll().stream()
                .map(tc -> new TitleConditionResponse(
                        tc.getTitle().getId(),
                        tc.getTitle().getName(),
                        tc.getConditionType(),
                        tc.getConditionValue()))
                .collect(Collectors.toList());
    }

    public List<TitleConditionProgressResponse> getUserTitleProgress(String token) {
        String userId = jwtProvider.getUserId(jwtProvider.getTokenWithoutBearer(token));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("유저가 존재하지 않습니다."));

        return titleConditionRepository.findAll().stream()
                .map(tc -> {
                    int progress = calculateUserProgress(userId, tc.getConditionType(), tc.getConditionValue());
                    int required = parseConditionValue(tc.getConditionValue());
                    return new TitleConditionProgressResponse(
                            tc.getTitle().getId(),
                            tc.getTitle().getName(),
                            tc.getConditionType(),
                            tc.getConditionValue(),
                            progress,
                            progress >= required
                    );
                }).collect(Collectors.toList());
    }

    private int calculateUserProgress(String userId, String conditionType, String conditionValue) {
        return switch (conditionType) {
            case "COLLECTION" -> userCollectionRepository.countByUserId(userId);
            case "INGREDIENT" -> userIngredientRepository.findByUserId(userId)
                    .stream()
                    .mapToInt(i -> i.getQuantity())
                    .sum();
            case "COLLECTION_NAME" -> userCollectionRepository.findByUserId(userId)
                    .stream()
                    .anyMatch(c -> c.getCollection().getName().equals(conditionValue)) ? 1 : 0;
            case "COLLECTION_NAMES" -> {
                List<String> requiredNames = Arrays.asList(conditionValue.split(","));
                List<String> userCollectionNames = userCollectionRepository.findByUserId(userId)
                        .stream().map(c -> c.getCollection().getName()).toList();
                boolean allCompleted = requiredNames.stream().allMatch(userCollectionNames::contains);
                yield allCompleted ? 1 : 0;
            }
            case "ALL_COLLECTIONS" -> {
                long total = collectionRepository.count();
                long userCount = userCollectionRepository.countByUserId(userId);
                yield userCount >= total ? 1 : 0;
            }
            case "ALL_INGREDIENTS" -> {
                long total = ingredientRepository.count();
                long userCount = userIngredientRepository.findByUserId(userId)
                        .stream().filter(i -> i.getQuantity() > 0).count();
                yield userCount >= total ? 1 : 0;
            }
            default -> 0;
        };
    }


    private int parseConditionValue(String value) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 1;
        }
    }
}
