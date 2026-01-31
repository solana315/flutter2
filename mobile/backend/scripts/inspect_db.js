const appointmentsModel = require('../models/appointement_sqlite');

(async () => {
  try {
    console.log('Checking appointments in SQLite...');
    let rows = await appointmentsModel.getAll();
    console.log('Found', rows.length, 'rows');
    if (rows.length === 0) {
      console.log('No rows found — inserting a sample appointment...');
      const tomorrow = new Date(Date.now() + 24 * 60 * 60 * 1000);
      const sample = {
        id_medico: 1,
        hora: '14:00:00',
        tipo_de_marcacao: 'Implantologia',
        status: 'confirmada',
        data_consulta: tomorrow.toISOString(),
      };
      const created = await appointmentsModel.create(sample);
      console.log('Inserted:', created);
      rows = await appointmentsModel.getAll();
    }

    console.log('All appointments:');
    console.log(JSON.stringify(rows, null, 2));
  } catch (err) {
    console.error('Error inspecting DB:', err);
  } finally {
    process.exit(0);
  }
})();
