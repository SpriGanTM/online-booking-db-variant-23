<?php

class ServiceRepository extends AbstractRepository
{
    protected string $table = 'services';

    public function getServicesWithCategory(
        int $categoryId
    ): array {

        $sql = "SELECT * FROM services
                WHERE category_id = :category_id";

        $stmt = $this->pdo->prepare($sql);

        $stmt->execute([
            'category_id' => $categoryId
        ]);

        return $stmt->fetchAll();
    }
}
