package still88.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import still88.backend.entity.Recipe;

import java.util.List;

@Repository
public interface RecipeRepository extends JpaRepository<Recipe, Long> {

    List<Recipe> findRecipeIdByRecipeCategory(String category);

    List<Recipe> findAllByRecipeNameContaining(String searching);

    Recipe findByRecipeName(String recipeName);

    Recipe findByRecipeId(int recipeId);
}
