package org.kuenteco.backend.repository.slave;

import java.util.List;
import java.util.Optional;
import org.kuenteco.backend.dto.logic.category.TransactionsByCategoryDTO;
import org.kuenteco.backend.entity.Category;
import org.kuenteco.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@Transactional(transactionManager = "slaveTransactionManager", readOnly = true)
public interface SlaveCategoryRepository extends JpaRepository<Category, Integer> {
    List<Category> findByUser(User user);

    Optional<Category> findByIdAndUser(Integer id, User user);

    @Query(
            value =
                    """
    SELECT v.* FROM vw_transactions_by_category v
    JOIN kuentecouser u ON v.owner_user_id = u.id
    WHERE u.email = :email
    """,
            nativeQuery = true)
    List<TransactionsByCategoryDTO> getTransactionsByCategoryAndUserEmail(
            @Param("email") String email);
    Optional<Category> getCategoryByUserAndId(User user, Integer id);
}
