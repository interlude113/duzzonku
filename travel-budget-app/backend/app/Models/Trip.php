<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Trip extends Model
{
    // 一括代入を許可するカラム
    protected $fillable = [
        'user_id',
        'name',
        'budget',
        'start_date',
        'end_date',
    ];

    // 1つの旅行は複数の支出を持つ
    public function expenses()
    {
        return $this->hasMany(Expense::class);
    }
}