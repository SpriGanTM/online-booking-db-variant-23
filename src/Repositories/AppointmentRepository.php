<?php

class AppointmentRepository
    extends AbstractRepository
{
    protected string $table = 'appointments';

    public function getAppointmentsByDate(
        string $date
    ): array {

        $sql = "SELECT * FROM appointments
                WHERE DATE(appointment_datetime)
                = :date";

        $stmt = $this->pdo->prepare($sql);

        $stmt->execute([
            'date' => $date
        ]);

        return $stmt->fetchAll();
    }

    public function createAppointment(
        int $clientId,
        int $specialistId,
        int $serviceId,
        string $datetime,
        string $status
    ): int {

        try {

            $this->pdo->beginTransaction();

            $checkSql = "
                SELECT COUNT(*)
                FROM appointments
                WHERE specialist_id = :specialist_id
                AND appointment_datetime =
                :appointment_datetime
            ";

            $checkStmt =
                $this->pdo->prepare($checkSql);

            $checkStmt->execute([
                'specialist_id' => $specialistId,
                'appointment_datetime' => $datetime
            ]);

            if (
                $checkStmt->fetchColumn() > 0
            ) {
                throw new RepositoryException(
                    'Данное время уже занято'
                );
            }

            $sql = "
                INSERT INTO appointments
                (
                    client_id,
                    specialist_id,
                    service_id,
                    appointment_datetime,
                    status
                )
                VALUES
                (
                    :client_id,
                    :specialist_id,
                    :service_id,
                    :appointment_datetime,
                    :status
                )
            ";

            $stmt = $this->pdo->prepare($sql);

            $stmt->execute([
                'client_id' => $clientId,
                'specialist_id' => $specialistId,
                'service_id' => $serviceId,
                'appointment_datetime' => $datetime,
                'status' => $status
            ]);

            $this->pdo->commit();

            return (int)$this->pdo->lastInsertId();

        } catch (PDOException $e) {

            $this->pdo->rollBack();

            throw new RepositoryException(
                'Ошибка создания записи: '
                . $e->getMessage()
            );
        }
    }

    public function updateStatus(
        int $id,
        string $status
    ): bool {

        $sql = "
            UPDATE appointments
            SET status = :status
            WHERE id = :id
        ";

        $stmt = $this->pdo->prepare($sql);

        return $stmt->execute([
            'status' => $status,
            'id' => $id
        ]);
    }
}
