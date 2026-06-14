<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\Request;

trait HasAdvancedFilter
{
    protected function applySearch(Builder $query, Request $request, array $fields): Builder
    {
        if ($search = $request->input('search')) {
            $query->where(function (Builder $q) use ($search, $fields) {
                foreach ($fields as $field) {
                    $q->orWhere($field, 'like', "%{$search}%");
                }
            });
        }
        return $query;
    }

    protected function applySort(Builder $query, Request $request, array $allowedFields = ['created_at']): Builder
    {
        $field = $request->input('sort_field', 'created_at');
        $dir = $request->input('sort_dir', 'desc');

        if (! in_array($field, $allowedFields)) {
            $field = 'created_at';
        }
        if (! in_array($dir, ['asc', 'desc'])) {
            $dir = 'desc';
        }

        return $query->orderBy($field, $dir);
    }

    protected function perPage(Request $request): int
    {
        return min((int) $request->input('per_page', 15), 100);
    }
}
