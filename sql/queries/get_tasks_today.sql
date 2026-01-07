-- GET /tasks/today
-- 今日やるべきタスクを取得する

-- Issue: #12 GET /tasks/today 詳細設計
-- period_key は API 側で生成する
-- SQLite / JST 前提

-- :today = '2025-01-08'
-- :daily_key = '2025-01-08'
-- :weekly_key = '2025-W02'

-- 単発タスク
SELECT
  t.id,
  t.title,
  t.task_type,
  t.period_type,
  t.due_date
FROM tasks t
WHERE
  t.task_type = 'single'
  AND t.due_date = :today
  AND t.completed_at IS NULL

UNION ALL

-- 周期タスク（daily / weekly）
SELECT
  t.id,
  t.title,
  t.task_type,
  t.period_type,
  NULL AS due_date
FROM tasks t
LEFT JOIN task_executions te
  ON te.task_id = t.id
  AND (
    (t.period_type = 'daily'  AND te.period_key = :daily_key)
    OR
    (t.period_type = 'weekly' AND te.period_key = :weekly_key)
  )
WHERE
  t.task_type = 'periodic'
  AND t.completed_at IS NULL
  AND t.current_period_start <= :today
  AND te.id IS NULL;
