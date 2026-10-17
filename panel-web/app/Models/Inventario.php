<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Inventario extends Model
{
    protected $table = 'inventario';
    protected $primaryKey = 'id_inventario';
    public $timestamps = false;

    protected $fillable = ['nombre_art', 'cantidad', 'minimo', 'id_tesorero'];
}