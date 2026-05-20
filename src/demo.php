<?php

require_once 'config.php';

require_once 'src/Database.php';

require_once
    'src/Exceptions/RepositoryException.php';

require_once
    'src/Repositories/AbstractRepository.php';

require_once
    'src/Repositories/ClientRepository.php';

require_once
    'src/Repositories/ServiceRepository.php';

require_once
    'src/Repositories/AppointmentRepository.php';

try {

    $pdo = Database::getConnection();

    $clientRepository =
        new ClientRepository($pdo);

    $appointmentRepository =
        new AppointmentRepository($pdo);

    $serviceRepository =
        new ServiceRepository($pdo);

    echo '<pre>';

    echo "ВСЕ КЛИЕНТЫ:\n";

    print_r(
        $clientRepository->findAll()
    );

    echo "\nКЛИЕНТ ПО ID:\n";

    print_r(
        $clientRepository->findById(1)
    );

    echo "\nДОБАВЛЕНИЕ КЛИЕНТА:\n";

    $newClientId =
        $clientRepository->create([
            'name' => 'Иван Иванов',
            'phone' => '+79991234567',
            'email' => 'ivan@example.com'
        ]);

    echo "Создан клиент ID:
          {$newClientId}\n";

    echo "\nСОЗДАНИЕ ЗАПИСИ:\n";

    $appointmentId =
        $appointmentRepository
            ->createAppointment(
                $newClientId,
                1,
                1,
                '2026-05-25 12:00:00',
                'new'
            );

    echo "Создана запись ID:
          {$appointmentId}\n";

    echo "\nОБНОВЛЕНИЕ СТАТУСА:\n";

    $appointmentRepository->updateStatus(
        $appointmentId,
        'confirmed'
    );

    echo "Статус обновлён\n";

    echo "\nУДАЛЕНИЕ ЗАПИСИ:\n";

    $appointmentRepository->delete(
        $appointmentId
    );

    echo "Запись удалена\n";

    echo '</pre>';

} catch (RepositoryException $e) {

    echo 'Ошибка репозитория: '
         . $e->getMessage();

} catch (PDOException $e) {

    echo 'Ошибка базы данных: '
         . $e->getMessage();

} catch (Exception $e) {

    echo 'Общая ошибка: '
         . $e->getMessage();
}
