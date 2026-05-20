<?php

class ClientRepository extends AbstractRepository
{
    protected string $table = 'clients';

    public function findByPhone(
        string $phone
    ): ?array {

        $sql = "SELECT * FROM clients
                WHERE phone = :phone";

        $stmt = $this->pdo->prepare($sql);

        $stmt->execute([
            'phone' => $phone
        ]);

        $result = $stmt->fetch();

        return $result ?: null;
    }

    public function findByEmail(
        string $email
    ): ?array {

        $sql = "SELECT * FROM clients
                WHERE email = :email";

        $stmt = $this->pdo->prepare($sql);

        $stmt->execute([
            'email' => $email
        ]);

        $result = $stmt->fetch();

        return $result ?: null;
    }

    public function create(array $data): int
    {
        $sql = "INSERT INTO clients
                (name, phone, email)
                VALUES
                (:name, :phone, :email)";

        $stmt = $this->pdo->prepare($sql);

        $stmt->execute([
            'name' => $data['name'],
            'phone' => $data['phone'],
            'email' => $data['email']
        ]);

        return (int)$this->pdo->lastInsertId();
    }
}
